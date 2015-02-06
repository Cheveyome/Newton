//
//  Geometry.swift
//  NewtonWars
//
//  Created by Lukas Hoffmann on 21.01.15.
//  Copyright (c) 2015 Lukas Hoffmann. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

// Takes a CGVector and a CGFLoat.
// Returns a new CGFloat where each component of v has been multiplied by m.
func vectorMultiply(v: CGVector, m: CGFloat) -> CGVector {
    return CGVectorMake(v.dx * m, v.dy * m)
}
// Takes two CGPoints.
// Returns a CGVector representing a direction from p1 to p2.
func vectorBetweenPoints(p1: CGPoint, p2: CGPoint) -> CGVector {
    return CGVectorMake(p2.x - p1.x, p2.y - p1.y)
}
// Takes a CGVector.
// Returns a CGFloat containing the length of the vector, calculated using
// Pythagoras' theorem.
func vectorLength(v: CGVector) -> CGFloat {
    return CGFloat(sqrtf(powf(Float(v.dx), 2) + powf(Float(v.dy), 2)))
}
// Takes two CGPoints. Returns a CGFloat containing the distance between them,
// calculated with Pythagoras' theorem.
func pointDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
    return CGFloat(sqrtf(powf(Float(p2.x - p1.x), 2) + powf(Float(p2.y - p1.y), 2)))
}

// Takes a CGFloat (a angle in Degree) and calculates a thrust vector
func degreeToVector(degree: CGFloat) -> CGVector {
    let radian = degree * CGFloat(M_PI) / CGFloat(180)
    let x = cos(radian)
    let y = sin(radian)
    return CGVectorMake(x, y)
}

func vectorToDegree(vector: CGVector) -> CGFloat {
    let degree = atan2(vector.dy, vector.dx) * CGFloat(180) / CGFloat(M_PI)
    return degree
}

func randomPosition(size: CGSize, border: Int = 0) -> CGPoint {
    let x = CGFloat(border + arc4random_uniform(UInt32(Int(size.width) - 2 * border)))
    let y = CGFloat(border + arc4random_uniform(UInt32(Int(size.height) - 2 * border)))
    return CGPointMake(x, y)
}

class planet {
    var radius: CGFloat = CGFloat(20.0)
    var position: CGPoint = CGPointMake(CGFloat(0), CGFloat(0))
}

var newtonPlanets: [planet] = []

func initPlanets (numberOfPlanets: Int, size: CGSize) {
    var collisionTest = false
    for var i = 0; i < numberOfPlanets; i++ {
        
        let x = CGFloat(150 + arc4random_uniform(UInt32(Int(size.width) - 300)))
        let y = CGFloat(150 + arc4random_uniform(UInt32(Int(size.height) - 300)))
        let r = CGFloat(20 + arc4random_uniform(UInt32(60)))
        
        var newPlanet = planet()
        newPlanet.radius = r
        newPlanet.position = CGPointMake(x, y)
        
        //Collision testing
        if i > 0 {
            for var j = 0; j < newtonPlanets.count; j++ {
                let distance = pointDistance(newPlanet.position, newtonPlanets[j].position)
                let combinedRadius = (newPlanet.radius + newtonPlanets[j].radius + 100)
                if distance < combinedRadius {
                    collisionTest = true
                }
            }
        }
        
        if collisionTest == true {
            --i
            collisionTest = false
        } else {
            newtonPlanets.append(newPlanet)
            collisionTest = false
        }
    }
}

