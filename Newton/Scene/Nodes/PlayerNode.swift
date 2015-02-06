//
//  PlayerNode.swift
//  NewtonWars
//
//  Created by Lukas Hoffmann on 21.01.15.
//  Copyright (c) 2015 Lukas Hoffmann. All rights reserved.
//

import UIKit
import SpriteKit
import Foundation

class PlayerNode: SKNode {
    override init() {
        super.init()
        //name = "Player \(self)"
        initNodeGraph(Color: SKColor.redColor())
        initPhysicsBody()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    private func initNodeGraph(Color color: SKColor) {
        let label = SKLabelNode(fontNamed: "Courier")
        label.fontColor = color
        label.fontSize = 40
        label.text = "."
        label.name = "PlayerDot"
        self.addChild(label)
    }
    
    private func initPhysicsBody() {
        let body = SKPhysicsBody(circleOfRadius: CGFloat(4))
        body.affectedByGravity = false
        body.categoryBitMask = PlayerCategory
        body.contactTestBitMask = MissileCategory
        body.collisionBitMask = 0
        body.fieldBitMask = 0 //no effect on gravity
        physicsBody = body
    }
    
    func receiveAttacker(attacker: SKNode, contact: SKPhysicsContact) {
        let path = NSBundle.mainBundle().pathForResource("EnemyExplosion", ofType: "sks")
        let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as SKEmitterNode
        explosion.numParticlesToEmit = 50
        explosion.position = contact.contactPoint
        scene!.addChild(explosion)
        runAction(SKAction.playSoundFileNamed("playerHit.wav", waitForCompletion: false))
    }
    
}
