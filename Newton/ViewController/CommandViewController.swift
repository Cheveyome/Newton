//
//  CommandViewController.swift
//  NewtonWars
//
//  Created by Lukas Hoffmann on 24.01.15.
//  Copyright (c) 2015 Lukas Hoffmann. All rights reserved.
//

import UIKit
import MultipeerConnectivity
//import PeerKit

class CommandViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MCBrowserViewControllerDelegate {

    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var anglePicker: UIPickerView!
    @IBOutlet weak var fireButton: UIButton!
    
    var appDelegate: AppDelegate!
    
    
    let titleArray: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    let titleArrayShort: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    var rowsShort = 10
    var connectionState = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //PeerKit.browse("newtonwars")
        // Do any additional setup after loading the view.
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let defaults = NSUserDefaults.standardUserDefaults()
        let displayName = defaults.stringForKey("username")
        appDelegate.mpcHandler.setupPeerWithDisplayName(displayName!)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
    }
    
    func connectWithPlayer(){
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    func peerChangedStateWithNotification(notification: NSNotification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.objectForKey("state") as Int
        
        if state == MCSessionState.Connected.rawValue {
            // Peer Connected
            println("Connected")
            connectionState = true
            stationLabel.text = "Station Command"
            self.fireButton.setTitle("Fire Missile", forState: UIControlState.Normal)
            self.fireButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            self.anglePicker.hidden = false
        } else if state == MCSessionState.Connecting.rawValue {
            // Peer is connecting
            println("Connecting")
            self.fireButton.setTitle("Connecting...", forState: UIControlState.Normal)
            self.fireButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
            self.anglePicker.hidden = true
        } else {
            // No connection
            println("Connection lost")
            self.fireButton.setTitle("Connect", forState: UIControlState.Normal)
            self.fireButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
            self.anglePicker.hidden = true
        }
    }
    
    func handleReceivedDataWithNotification(notification: NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let recievedData: NSData = userInfo["data"] as NSData
        
        let message = NSJSONSerialization.JSONObjectWithData(recievedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let senderPeerID: MCPeerID = userInfo["peerID"] as MCPeerID
        let senderDisplayName = senderPeerID.displayName
        
        println(message)
        println(senderDisplayName)
    }
    
    override func viewWillDisappear(animated: Bool) {
        //stopTransceiving()
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func fireButton(sender: AnyObject) {
        
        var sendArray: [Int] = [anglePicker.selectedRowInComponent(0), anglePicker.selectedRowInComponent(1), anglePicker.selectedRowInComponent(2), anglePicker.selectedRowInComponent(4), anglePicker.selectedRowInComponent(5), anglePicker.selectedRowInComponent(7), anglePicker.selectedRowInComponent(9)]
        
        let degreeInt1 = (sendArray[0] * 100 + sendArray[1] * 10 + sendArray[2])
        let degreeInt2 = sendArray[3] * 10 + sendArray[4]
        var degreeFloat = CGFloat(degreeInt1) + CGFloat(degreeInt2) * 0.01
        var thrustFloat = CGFloat(sendArray[5]) + CGFloat(sendArray[6]) * CGFloat(0.1) + CGFloat(1)

        println("Winkel: \(degreeFloat)° und Geschwindigkeit: \(thrustFloat)")
        
        if !connectionState {
        connectWithPlayer()
        }
        
        if connectionState {
            let messageDict: [String: CGFloat] = ["angle": degreeFloat, "thrust": thrustFloat]
            let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
            var error: NSError?
            
            appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
            println("Data send")
            if error != nil {
                println("error: \(error?.localizedDescription)")
            }
            
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 11
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rows = 1
        switch (component){
        case 0: rows = 4
        case 1: rows = rowsShort
        case 3, 6, 8, 10: rows = 1
        case 7: rows = 9
        default: rows = 10
        }
        return rows
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()

        let titleData = titleArray[row]
        let titleDataShort = titleArrayShort[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Courier", size: 18.0)!,
            NSForegroundColorAttributeName:UIColor.lightGrayColor()])
        
        switch (component) {
        case 3, 8:
            myTitle = NSAttributedString(string: ",", attributes: [NSFontAttributeName:UIFont(name: "Courier", size: 18.0)!,
            NSForegroundColorAttributeName:UIColor.lightGrayColor()])
        case 6:
            myTitle = NSAttributedString(string: "°", attributes: [NSFontAttributeName:UIFont(name: "Courier", size: 22.0)!,
            NSForegroundColorAttributeName:UIColor.lightGrayColor()])
        case 10:
            myTitle = NSAttributedString(string: "m/s", attributes: [NSFontAttributeName:UIFont(name: "Courier", size: 14.0)!,
            NSForegroundColorAttributeName:UIColor.lightGrayColor()])
        case 7:
            myTitle = NSAttributedString(string: titleDataShort, attributes: [NSFontAttributeName:UIFont(name: "Courier", size: 22.0)!,
                NSForegroundColorAttributeName:UIColor.lightGrayColor()])
        default:
            myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Courier", size: 22.0)!,
            NSForegroundColorAttributeName:UIColor.lightGrayColor()])
        }
        
        switch (component) {
        case 0, 1, 2, 7:
            pickerLabel.textAlignment = NSTextAlignment.Right
        case 4, 5, 6, 9, 10:
            pickerLabel.textAlignment = NSTextAlignment.Left
        default:
            pickerLabel.textAlignment = NSTextAlignment.Center
        }

        pickerLabel.attributedText = myTitle
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let pickerWidth = pickerView.bounds.size.width / 20
        var componentWidth = pickerWidth
        switch (component){
        //case 0, 6: componentWith = pickerWith * 3
        case 0, 1, 2, 4, 5, 7, 9: componentWidth = 30
        case 3, 8: componentWidth = 20
        case 6: componentWidth = 50
        case 10: componentWidth = 100
        default: componentWidth = pickerWidth
        }
        return componentWidth
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //var short = false
        if component == 0 {
            if row == 3 {
                rowsShort = 6
                println("min. 300° sind ausgewählt")
            } else {
            rowsShort = 10
            }
            pickerView.reloadComponent(1)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let messageDict: [String: CGFloat] = ["angle": 0, "thrust": 0]
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var error: NSError?
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        println("Disconnected")
        if error != nil {
            println("error: \(error?.localizedDescription)")
        }
        appDelegate.mpcHandler.advertiseSelf(false)
    }
}
