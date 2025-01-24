//
//  MockData.swift
//  Impromptu
//
//  Created by Shane Brelesky on 1/24/25.
//

import Foundation


struct MockData {
    static let question = Question(id: "SA5uPK9W6f6m7f3PvNH1", text: "Hello there _____, let's make it a little longer ... _____")
    static let game = Game(id: "1234", status: .created)
    
    static let players = [
        Player(id: "1", name: "Player 1", isCreator: true, isReady: true, points: 0),
        Player(id: "2", name: "Player 2", isCreator: true, isReady: true, points: 0)
    ]
    
    static var manager: GameManager = {
        let gameManager = GameManager.shared
        gameManager.players = MockData.players
        gameManager.questions = [MockData.question]
        gameManager.playerId = players.first?.id
        gameManager.game = MockData.game
        
        return gameManager
    }()
}
