//
//  PlanetNode.swift
//  NewtonWars
//
//  Created by Lukas Hoffmann on 23.01.15.
//  Copyright (c) 2015 Lukas Hoffmann. All rights reserved.
//

import UIKit
import SpriteKit
import Foundation

class PlanetNode: SKNode {

    override init() {
        super.init()
        
        createPlanet()
        createGravity()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Hier werden die Planeten mit dem PhysicsBody und dem Gravitationsfeld erstellt
    func createPlanet() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let movePlanet = defaults.boolForKey("movePlanet")
        let i = arc4random_uniform(34)+1
        let planet = SKSpriteNode(imageNamed: "Planet \(i).png")
        planet.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(150))
        planet.physicsBody?.fieldBitMask = 0
        planet.physicsBody?.angularDamping = 0
        planet.physicsBody?.affectedByGravity = false
        planet.physicsBody?.categoryBitMask = PlanetCategory
        planet.physicsBody?.contactTestBitMask = MissileCategory
        
        if movePlanet == true {
            planet.physicsBody?.dynamic = true
            planet.physicsBody?.linearDamping = 5
            planet.physicsBody?.density = 0.01
        } else {
            planet.physicsBody?.dynamic = false
            planet.physicsBody?.linearDamping = 0
            planet.physicsBody?.density = 1
        }
        planet.name = "PlanetBody"
        self.addChild(planet)
    }
    
    func createGravity() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let gravityField = SKFieldNode.radialGravityField()
        if defaults.stringForKey("levelOfGravity") == "low" {
            gravityField.strength = 5
        } else if defaults.stringForKey("levelOfGravity") == "high" {
            gravityField.strength = 11
        } else {
            gravityField.strength = 8
        }
        gravityField.name = "Gravity"
        self.childNodeWithName("PlanetBody")?.addChild(gravityField)
        //self.addChild(gravityField)
    }
}
