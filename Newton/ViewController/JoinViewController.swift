//
//  JoinViewController.swift
//  NewtonWars
//
//  Created by Lukas Hoffmann on 24.01.15.
//  Copyright (c) 2015 Lukas Hoffmann. All rights reserved.
//

import UIKit


class JoinViewController: UIViewController {
    

    @IBOutlet weak var displayNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        displayNameTextField.text = defaults.stringForKey("username")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(displayNameTextField.text, forKey: "username")
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
