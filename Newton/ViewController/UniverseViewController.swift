//
//  UniverseViewController.swift
//  Newton
//
//  Created by Lukas Hoffmann on 25.01.15.
//  Copyright (c) 2015 Lukas Hoffmann. All rights reserved.
//

import UIKit
import SpriteKit


class UniverseViewController: UIViewController {
    
    @IBOutlet weak var skview: SKView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //let skView = self.view as SKView
        skview.showsFPS = true
        skview.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skview.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        let scene = UniverseScene(size: self.view.bounds.size)
        
        scene.scaleMode = .AspectFill
        scene.backgroundColor = UIColor.blackColor()
        skview.presentScene(scene)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.skview.scene?.removeAllChildren()
        self.skview.removeFromSuperview()
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
