//
//  UniverseScene.swift
//  Newton
//
//  Created by Lukas Hoffmann on 25.01.15.
//  Copyright (c) 2015 Lukas Hoffmann. All rights reserved.
//

import UIKit
import SpriteKit
import MultipeerConnectivity
//import PeerKit Framework muss noch importiert werden und Netzwerkcode überprüft werden

class UniverseScene: SKScene, SKPhysicsContactDelegate, MCBrowserViewControllerDelegate {

    let vc = UniverseViewController()
    private let players = SKNode()
    private let planets = SKNode()
    private let playerBullets = SKNode()
    var settingBoundries = false
    var appDelegate: AppDelegate!
    var playerPositions: [String: CGPoint] = ["Player 1": CGPoint(x: 50, y: 50)]
    var playerNames = [String: String]()
    var playerNumber = [String: String]()
    var playerColor = [String: SKColor]()
    var score = [String: Int]()
    var killed = [String: Int]()
    var shots = [String: Int]()
    var scoreBoardLabels = [String: SKLabelNode]()
    var scoreBoardScore = [String: SKLabelNode]()
    
    init(size:CGSize, numberOfPlanets: Int) {
        super.init(size: size)
        
        // Grafik erstellen: Hintergrund und Planeten
        backgroundColor = SKColor.blackColor()
        let defaults = NSUserDefaults.standardUserDefaults()
        let noOfPlanets = Int(defaults.integerForKey("numberOfPlanets"))
        newtonPlanets = []
        initPlanets(noOfPlanets, size)  // in Geometry.swift
        initPlanetNodes()
        addChild(planets)
        settingBoundries = defaults.boolForKey("boundries")
        // Die Gravitation der Welt (Szene) einstellen
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        //ScoreBoard
        initScoreBoard()
        
        //Spielelemente hinzufügen
        addChild(playerBullets)
        
        addNewPlayer("Host", color: SKColor.lightGrayColor())
        playerColor["Host"] = SKColor.lightGrayColor()
        //addChild(players)

        // Networking: den Netzwerk-Host starten
        //advertise("newtonwars")
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let displayName = defaults.stringForKey("hostname")
        appDelegate.mpcHandler.setupPeerWithDisplayName(displayName!)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
    }
    
    func peerChangedStateWithNotification(notification: NSNotification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.objectForKey("state") as Int
        
        
        if state == MCSessionState.Connected.rawValue {
            // Peer Connected
            let newPlayer = appDelegate.mpcHandler.session.connectedPeers.last!.displayName
            println("\(newPlayer) has joined the game")
            if playerNames["Player 1"] == nil {
                initPlayer(newPlayer, number: 1, color: SKColor.greenColor())
            } else if playerNames["Player 2"] == nil {
                initPlayer(newPlayer, number: 2, color: SKColor.redColor())
            } else if playerNames["Player 3"] == nil {
                initPlayer(newPlayer, number: 2, color: SKColor.cyanColor())
            } else if playerNames["Player 4"] == nil {
                initPlayer(newPlayer, number: 2, color: SKColor.blueColor())
            } else if playerNames["Player 5"] == nil {
                initPlayer(newPlayer, number: 2, color: SKColor.yellowColor())
            } else if playerNames["Player 6"] == nil {
                initPlayer(newPlayer, number: 2, color: SKColor.purpleColor())
            } else if playerNames["Player 7"] == nil {
                initPlayer(newPlayer, number: 2, color: SKColor.orangeColor())
            } else {
                println("Too many players")
                // removeInactivePlayers Funktion noch erstellen und hier aufrufen
                removeInactivePlayer()
            }
            

        } else if state == MCSessionState.Connecting.rawValue {
            // Peer is connecting
            println("Connecting")

        } else {
            // No connection
            println("Connection lost")
            removeInactivePlayer()
        }
    }
    
    func initPlayer(name: String, number: Int, color: SKColor){
        playerNames["Player \(number)"] = name
        playerNumber[name] = "Player \(number)"
        playerColor[name] = color
        addNewPlayer(name, color: color)
        scoreBoardLabels["Player \(number)"]?.text = name
        scoreBoardLabels["Player \(number)"]?.fontColor = color
        self.addChild(scoreBoardLabels["Player \(number)"]!)
        scoreBoardScore["Player \(number)"]?.text = "0"
        scoreBoardScore["Player \(number)"]?.fontColor = color
        self.addChild(scoreBoardScore["Player \(number)"]!)
    }
    //Die Labels für die Scores am oben Rand. Evtl. müssen die ganz anders initiiert werden.
    func initScoreBoard(){
        for i in 1...7 {
            let scoreName = SKLabelNode(fontNamed: "Courier")
            scoreName.name = "Player \(i)"
            scoreName.fontSize = 20
            scoreName.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
            scoreName.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            scoreName.position = CGPointMake(CGFloat(i - 1) * frame.width / 7, frame.height)
            self.scoreBoardLabels["Player \(i)"] = scoreName
        }
        for i in 1...7 {
            let scoreLabel = SKLabelNode(fontNamed: "Courier")
            scoreLabel.name = "scoreName\(i)"
            scoreLabel.fontSize = 20
            scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
            scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            scoreLabel.position = CGPointMake(CGFloat(i - 1) * frame.width / 7, frame.height - 22)
            self.scoreBoardScore["Player \(i)"] = scoreLabel
        }
    }
    
    func updateScoreBoard(){
        // hier muss ich mir noch überlegen wie ich die Label update
    }
    func handleReceivedDataWithNotification(notification: NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let recievedData: NSData = userInfo["data"] as NSData
        
        let message = NSJSONSerialization.JSONObjectWithData(recievedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let senderPeerID: MCPeerID = userInfo["peerID"] as MCPeerID
        let senderDisplayName = senderPeerID.displayName
        var degreeFloat: CGFloat = 0.0
        var thrustFloat: CGFloat = 1.0
        let json = JSON(message)
        if let degree = json["angle"].float {
            //Der Winkel
            degreeFloat = CGFloat(degree)
        }
        
        if let thrust = json["thrust"].float {
            //Die Abschussgeschwindigkeit
            thrustFloat = CGFloat(thrust)
        }
        println("\(senderDisplayName): \(degreeFloat)° & \(thrustFloat) m/s")

        if thrustFloat == 0 {
            println("\(senderDisplayName) left the game")
            playerPositions.removeValueForKey(senderDisplayName)
            playerNames.removeValueForKey(playerNumber[senderDisplayName]!)
            playerColor.removeValueForKey(senderDisplayName)
            score.removeValueForKey(senderDisplayName)
            killed.removeValueForKey(senderDisplayName)
            shots.removeValueForKey(senderDisplayName)
            scoreBoardLabels[playerNumber[senderDisplayName]!]?.removeFromParent()
            scoreBoardScore[playerNumber[senderDisplayName]!]?.removeFromParent()
            playerNumber.removeValueForKey(senderDisplayName)
            removePlayer(senderDisplayName)
        } else {
            let bullet = BulletNode.bullet(senderDisplayName, start: playerPositions[senderDisplayName]!, angle: degreeFloat, velocity: thrustFloat)
            playerBullets.addChild(bullet)
            bullet.shootBullet()
            shots[senderDisplayName] = shots[senderDisplayName]! + 1
        }
    }
    
    func addNewPlayer(name: String, color: SKColor){
        let player = SKLabelNode(fontNamed: "Courier")
        player.name = name
        player.position = randomPosition(size, border: 20)
        // Hier wird überprüft ob an der Position schon ein Planet oder irgendetwas anderes ist
        while nodesAtPoint(player.position).count > 0 {
            player.position = randomPosition(size, border: 20)
        }
        player.fontColor = color
        player.fontSize = 60
        player.text = "."
        let body = SKPhysicsBody(circleOfRadius: CGFloat(5)  )
        body.affectedByGravity = false
        body.categoryBitMask = PlayerCategory
        body.contactTestBitMask = MissileCategory
        body.collisionBitMask = 0
        body.fieldBitMask = 0
        body.dynamic = false
        player.physicsBody = body
        playerPositions[name] = player.position
        if score[name] == nil {
            score[name] = 0
        }
        if killed[name] == nil {
            killed[name] = 0
        }
        if shots[name] == nil {
            shots[name] = 0
        }
        self.addChild(player)
    }
    
    func removePlayer(name: String){
        if (self.childNodeWithName(name)) != nil {
            self.childNodeWithName(name)?.removeFromParent()
        }
    }
    
    func removeInactivePlayer(){
        var conPeer = appDelegate.mpcHandler.session.connectedPeers
        var connected = [String]()                                   // Ein Array der noch verbundenen Spieler
        var playerList = [String](playerNumber.keys)                    // Ein Array der eingetragenen Spieler welches evtl. größer ist
        for peers in conPeer {
            connected.append(peers.displayName)
        }
        println("Momentan sind folgende Peers verbunden: \(connected)")
        println("Folgende Spieler sind noch registriert: \(playerList)")
        if connected.count != playerList.count {
            // Die Listen sind unterschiedlich lang und ein Spieler muss manuell entfernt werden
            for names in playerList {
                if contains(connected, names){
                    println("\(names) is still connected")
                } else {
                    println("\(names) has disconnected and has to be removed by the host")
                    removePlayer(names)
                }
            }
        }
    }
   
    func initPlanetNodes() {
        let planetCount = newtonPlanets.count
        for var i = 0; i < planetCount; i++ {
            let randomPlanet = newtonPlanets[i]
            let planetNode = PlanetNode()
            planetNode.name = "Planet \(i)"
            planetNode.position = randomPlanet.position
            planetNode.setScale(CGFloat(randomPlanet.radius/150))
            planets.addChild(planetNode)
        }
    }
    
    // Direkte Spielereingaben beim Host werden hier verarbeitet. Sollte längerfristig entfallen
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
            /* Called when a touch begins */
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                //Falls in die rechte untere Ecke gedrückt wird --> Neustart des Levels
                if CGRectContainsPoint(CGRectMake(frame.width, 0, -50.0, 50) , location) {
                    newtonPlanets = []
                    let transition = SKTransition.doorwayWithDuration(1.0)
                    let game = UniverseScene(size:frame.size)
                    view!.presentScene(game, transition: transition)
                    runAction(SKAction.playSoundFileNamed("gameStart.wav", waitForCompletion: false))
                }
                // Abschuss der Missile
                if !CGRectContainsPoint(CGRectMake(0.0, 0.0, 50.0, 50.0), location) {
                    //let bullet = BulletNode.bullet(from: self.players.childNodeWithName("Player 1")!.position, toward: location)
                    let movement = vectorBetweenPoints(self.childNodeWithName("Host")!.position, location)
                    let degree = vectorToDegree(vectorMultiply(movement, 1/vectorLength(movement)))
                    let bullet = BulletNode.bullet("Host", start: self.childNodeWithName("Host")!.position, angle: degree, velocity: CGFloat(2))
                    
                    playerBullets.addChild(bullet)
                    bullet.shootBullet()
                }
            }
    }
    
    // Hier wird die Position der Missles überprüft und falls notwendig auf die andere Seite des Bildschirms gesetzt
    private func updateBullets() {
        var bulletsToRemove:[BulletNode] = []
        for bullet in playerBullets.children as [BulletNode] {
            // Remove any bullets that have moved more then 100 points off-screen
            if settingBoundries == true {
                let extendedRect = CGRectMake(-100, -100, frame.width + 100, frame.height + 100)
                if !CGRectContainsPoint(extendedRect, bullet.position) {
                    //Mark bullet for removal
                    bulletsToRemove.append(bullet)
                    continue
                }
            // Set Bullets to the other side of the screen
            } else {
                let bulletPosition = (bullet.position.x, bullet.position.y)
                switch bulletPosition {
                    case let (x, y) where x < 0: bullet.position.x = frame.width
                    case let (x, y) where x > frame.width: bullet.position.x = 0
                    case let (x, y) where y < 0: bullet.position.y = frame.height
                    case let (x, y) where y > frame.height: bullet.position.y = 0
                    default: bullet.position = bullet.position
                }
                
                if bullet.position.x < 0 {
                    bullet.position.x = frame.width
                }
            }
        }
        playerBullets.removeChildrenInArray(bulletsToRemove)    
    }
    
    // Hier wird festgestellt welche Physik-Körper sich getroffen haben (Missle, Player, Planet) und was dann passiert
    func didBeginContact(contact: SKPhysicsContact) {
        var playerHit = false
        var missileContact = contact.bodyA
        var playerContact = contact.bodyA
        var planetContact = contact.bodyA
        
        switch (contact.bodyA.categoryBitMask) {
            case PlayerCategory:
                playerContact = contact.bodyA
                playerHit = true
            case PlanetCategory:
                planetContact = contact.bodyA
            default:
                missileContact = contact.bodyA
        }
        
        switch (contact.bodyB.categoryBitMask) {
            case PlayerCategory:
                playerContact = contact.bodyB
                playerHit = true
            case PlanetCategory:
                planetContact = contact.bodyB
            default:
                missileContact = contact.bodyB
        }
        
        if playerHit == true {
            println("Missile trifft Spieler")
            // Es muss noch überprüft werden, welcher Spieler die Missile abgefeuert hat
            if (playerContact.node? != nil) {
                let playerName = playerContact.node!.name!
                if (self.childNodeWithName(playerName)) != nil {
                    self.removePlayer(playerName)
                    self.addNewPlayer(playerName, color: playerColor[playerName]!)
                }
                killed[playerName] = killed[playerName]! + 1
                println("\(playerName) wurde schon \(killed[playerName]!) mal getroffen.")
            }
            if (missileContact.node? != nil) {
                
                let shooterDict: NSDictionary = missileContact.node!.userData! as NSDictionary
                let shooter: String = shooterDict.valueForKey("Sender") as String
                score[shooter] = score[shooter]! + 1
                println("\(shooter) hat schon \(score[shooter]!) Treffer bei \(shots[shooter]!) Schüssen")
                var playerNumberString = playerNumber[shooter]
                scoreBoardScore[playerNumberString!]?.text = "Score: \(score[shooter]!)"
            }
        }

        playerBullets.removeChildrenInArray([missileContact.node!])
        let path = NSBundle.mainBundle().pathForResource("MissileExplosion", ofType: "sks")
        let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as SKEmitterNode
        explosion.numParticlesToEmit = 20
        explosion.position = contact.contactPoint
        scene!.addChild(explosion)
        runAction(SKAction.playSoundFileNamed("enemyHit.wav", waitForCompletion: false))
    }
    
    // Diese Funktion wird vor dem Zeichnen von jedem Frame aufgerufen
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered*/    
        updateBullets()
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
    }

    class func scene(size:CGSize, numberOfPlanets:Int) -> UniverseScene {
        return UniverseScene(size: size, numberOfPlanets: numberOfPlanets)
    }
    override convenience init(size:CGSize) {
        self.init(size: size, numberOfPlanets: 7)
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    // wird noch nicht benötigt
    /*
    func sendMessage (){
    let messageDict = ["angle": "data", "thrust": "thrust"]
    let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
    var error: NSError?
    
    appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
    println("Data send")
    if error != nil {
    println("error: \(error?.localizedDescription)")
    }
    }
    */
}
