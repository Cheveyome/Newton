//
//  BulletNode.swift
//  NewtonWars
//
//  Created by Lukas Hoffmann on 21.01.15.
//  Copyright (c) 2015 Lukas Hoffmann. All rights reserved.
//

import UIKit
import SpriteKit

class BulletNode: SKNode {
    var thrust: CGVector = CGVectorMake(0, 0)
    
    override init() {
        super.init()
        let dot = SKLabelNode(fontNamed: "Courier")
        dot.fontColor = SKColor.lightGrayColor()
        dot.fontSize = 30
        dot.text = "."
        dot.userData = ["Sender": "NoSender"]
        addChild(dot)
        let body = SKPhysicsBody(circleOfRadius: 1)
        body.dynamic = true
        body.categoryBitMask = MissileCategory
        body.mass = 0.01
        physicsBody = body
        name = "Bullet \(self)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let dx = aDecoder.decodeFloatForKey("thrustX")
        let dy = aDecoder.decodeFloatForKey("thrustY")
        thrust = CGVectorMake(CGFloat(dx), CGFloat(dy))
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeFloat(Float(thrust.dx), forKey: "thrustX")
        aCoder.encodeFloat(Float(thrust.dy), forKey: "thrustY")
    }

    class func bullet(sender: String, start: CGPoint, angle: CGFloat, velocity: CGFloat) -> BulletNode {
        let headingVector = degreeToVector(angle)
        let bullet = BulletNode()
        
        bullet.position = CGPointMake(start.x + (7 * headingVector.dx), start.y + (7 * headingVector.dy))
        bullet.thrust = vectorMultiply(headingVector, velocity)
        bullet.runAction(SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false))
        bullet.userData = ["Sender": sender]
        return bullet
    }

    func shootBullet() {
        physicsBody!.applyImpulse(thrust)
    }
    
}
