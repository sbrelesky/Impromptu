//
//  Game.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum GameStatus: Int, Codable {
    case created = 0 // Game has been created
    case started = 1 // Game has been started and is now in progress
    case questionCompleted = 2 // All players finished answering question
    case votingCompleted = 3 // All players finished voting
    case readyForNextRound = 4 // All players ready for next round
    case finished = 5 // Game has ended
}

struct Game: Codable {
    
    @DocumentID var id: String?
    var dateCreated: Timestamp
    var status: GameStatus
    
    enum CodingKeys: CodingKey {
        case id
        case dateCreated
        case status
    }
    
    init(id: String?, dateCreated: Timestamp = Timestamp(date: .now), status: GameStatus) {
        self.id = id
        self.dateCreated = dateCreated
        self.status = status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        dateCreated = try container.decode(Timestamp.self, forKey: .dateCreated)
        status = try container.decode(GameStatus.self, forKey: .status)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(status, forKey: .status)
    }
}


struct Player: Codable {
    @DocumentID var id: String?
    var name: String
    var isCreator: Bool? = false
    var isReady: Bool? = false
    var points: Int
}

struct Question: Codable {
    @DocumentID var id: String?
    var text: String
}

struct Answer: Codable {
    @DocumentID var id: String?
    var questionId: String
    var playerId: String
    var text: String?
    var votes: Int = 0
}


