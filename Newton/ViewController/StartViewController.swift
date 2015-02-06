//
//  StartViewController.swift
//  NewtonWars
//
//  Created by Lukas Hoffmann on 24.01.15.
//  Copyright (c) 2015 Lukas Hoffmann. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var hostButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        if UIDevice.currentDevice().model == "iPhone" {
            hostButton.hidden = true
        }
        println(UIDevice.currentDevice().model)

        // Do any additional setup after loading the view.
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

}
