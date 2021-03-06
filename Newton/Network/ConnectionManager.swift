//
//  ConnectionManager.swift
//  Newton
//
//  Created by Lukas Hoffmann on 25.01.15.
//  Copyright (c) 2015 Lukas Hoffmann. All rights reserved.
//

import Foundation
import PeerKit
import MultipeerConnectivity

protocol MPCSerializable {
    var mpcSerialized: NSData { get }
    init(mpcSerialized: NSData)
}

enum Event: String {
    case JoinGame = "JoinGame",
    MissileReady = "MissileReady",
    
    CancelAnswer = "CancelAnswer",
    Vote = "Vote",
    NextCard = "NextCard",
    EndGame = "EndGame"
}

struct ConnectionManager {

    // MARK: Properties

    static var peers: [MCPeerID] {
        if let session = PeerKit.session {
            return session.connectedPeers as [MCPeerID]
        }
        return [MCPeerID]()
    }

    static var otherPlayers: [Player] {
        if let session = PeerKit.session {
            return (session.connectedPeers as [MCPeerID]).map { Player(peer: $0) }
        }
        return [Player]()
    }

    static var allPlayers: [Player] { return [Player.getMe()] + ConnectionManager.otherPlayers }

    // MARK: Start

    static func start() {
        PeerKit.transceive("newtonwars")
    }

    // MARK: Event Handling

    static func onConnect(run: PeerBlock?) {
        PeerKit.onConnect = run
    }

    static func onDisconnect(run: PeerBlock?) {
        PeerKit.onDisconnect = run
    }

    static func onEvent(event: Event, run: ObjectBlock?) {
        if let run = run {
            PeerKit.eventBlocks[event.rawValue] = run
        } else {
            PeerKit.eventBlocks.removeValueForKey(event.rawValue)
        }
    }

    // MARK: Sending

    static func sendEvent(event: Event, object: [String: MPCSerializable]? = nil, toPeers peers: [MCPeerID]? = PeerKit.session?.connectedPeers as [MCPeerID]?) {
        var anyObject: [String: NSData]?
        if let object = object {
            anyObject = [String: NSData]()
            for (key, value) in object {
                anyObject![key] = value.mpcSerialized
            }
        }
        PeerKit.sendEvent(event.rawValue, object: anyObject, toPeers: peers)
    }

    static func sendEventForEach(event: Event, objectBlock: () -> ([String: MPCSerializable])) {
        for peer in ConnectionManager.peers {
            ConnectionManager.sendEvent(event, object: objectBlock(), toPeers: [peer])
        }
    }
}
