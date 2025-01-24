//
//  GameManager.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import FirebaseFirestore

@objc protocol GameManagerNotificationDelegate {
    func notifyGameDidUpdate()
}

protocol GameManagerDelegate: GameManagerNotificationDelegate { }

extension GameManagerDelegate where Self: UIViewController {
    
    func registerGameDidUpdateNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(notifyGameDidUpdate), name: Constants.Notifications.gameDidUpdate, object: nil)
    }
    
    func removeGameDidUpdateNotification() {
        NotificationCenter.default.removeObserver(self, name: Constants.Notifications.gameDidUpdate, object: nil)
    }
}

class GameManager {
    
    static let shared = GameManager()
    
    var game: Game?
    var players: [Player] = []
    var questions: [Question] = []
    
    var currentRound: Int = 0
    
    private var playerId: String?
    
    var code: String? {
        return game?.id
    }
    
    var currentPlayer: Player? {
        if let idx = players.firstIndex(where: { $0.id == playerId }) {
            return players[idx]
        }
        
        return nil
    }
    
    var question: Question? {
        return questions[currentRound]
    }
    
    weak var delegate: GameManagerNotificationDelegate?
    
    // Listeners
    private var gameListener: ListenerRegistration?
    private var playersListener: ListenerRegistration?
    private var answersListener: ListenerRegistration?
    
    private init() {}
    
    deinit {
        detachListeners()
    }

    func detachListeners() {
        gameListener?.remove()
        detachPlayers()
        detachAnswers()
    }
    
    func detachPlayers() {
        playersListener?.remove()
    }
    
    func detachAnswers() {
        answersListener?.remove()
    }
    
    
    func clean() {
        game = nil
        players = []
        questions = []
        currentRound = 0
        playerId = nil
        detachListeners()
    }
}

// MARK: - Fetch Methods

extension GameManager {
    
    func fetchGame(code: String, completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.fetchGame(code: code) { result in
            switch result {
            case .success(let game):
                self.game = game
                
                self.fetchPlayers(for: code) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        self.fetchQuestions(for: code, completion: completion)
                    }
                }
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func fetchPlayers(for gameCode: GameCode, completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.fetchPlayers(code: gameCode) { result in
            switch result {
            case .success(let players):
                self.players = players.sorted(by: { $0.points > $1.points })
                completion(nil)
            case .failure(let failure):
                completion(failure)
            }
        }
    }
    
    func fetchQuestions(for gameCode: GameCode, completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.fetchQuestions(code: gameCode) { result in
            switch result {
            case .success(let questions):
                self.questions = questions.sorted(by: { $0.id ?? "" < $1.id ?? "" })
                completion(nil)
            case .failure(let failure):
                completion(failure)
            }
        }
    }
    
    func fetchAnswers(completion: @escaping (Result<[Answer], Error>) -> ()) {
        guard let questionId = question?.id else { return }
        
        fetchAnswers(for: questionId, completion: completion)
    }
    
    func fetchAnswers(for questionId: String, completion: @escaping (Result<[Answer], Error>) -> ()) {
        guard let code = game?.id else { return }
        
        FirestoreManager.shared.fetchAnswers(code: code, questionId: questionId, completion: completion)
    }
    
}

// MARK: Observe Methods -

extension GameManager {
    
    func observeGame(completion: @escaping (Error?) -> ()) {
        gameListener?.remove()
        
        guard let code = game?.id else { return }
        
        gameListener = FirestoreManager.shared.observeGame(code: code) { result in
            switch result {
            case .success(let game):
                
                self.game = game
                // self.delegate?.updated()
                NotificationCenter.default.post(name: Constants.Notifications.gameDidUpdate, object: nil)

                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func observePlayers(completion: @escaping (Error?)->()) {
        playersListener?.remove()
        guard let code = game?.id else { return }
        playersListener = FirestoreManager.shared.observePlayers(code: code, completion: { result in
            switch result {
            case .success(let players):
                
//                switch changeType {
//                case .added:
//                    if self.players.contains(where: { $0.id == player.id }) == false {
//                        self.players.append(player)
//                    }
//                    
//                case .modified:
//                    if let index = self.players.firstIndex(where: { $0.id == player.id }) {
//                        self.players[index] = player
//                    }
//                case .removed:
//                   if let index = self.players.firstIndex(where: { $0.id == player.id }) {
//                       self.players.remove(at: index)
//                   }
//                }
                
                self.players = players.sorted(by: { $0.points > $1.points })
                
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    func observeAnswers(completion: @escaping (Result<[Answer], Error>) -> ()) {
        answersListener?.remove()
        guard let code = game?.id, let questionId = question?.id else { return }

        answersListener = FirestoreManager.shared.observeAnswers(with: code, for: questionId, completion: completion)
    }
    
    func createGame(name: String, completion: @escaping (Result<GameCode,Error>) -> ()) {
        // Create the actual game
        FirestoreManager.shared.createGame(name: name) { result in
            switch result {
            case .success(let code):
                
                // Set the questions for the game
                FirestoreManager.shared.setQuestionsFoGame(code: code) { result in
                    switch result {
                    case .success(let questions):
                        self.questions = questions
                        
                        // Join the game
                        FirestoreManager.shared.joinGame(code: code, name: name, isCreator: true) { result in
                            switch result {
                            case .success(let player):
                                self.playerId = player.id
                                completion(.success(code))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                            
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func joinGame(code: String, name: String, completion: @escaping (Error?) -> ()) {
        // Pull game from db
        FirestoreManager.shared.joinGame(code: code, name: name, isCreator: false) { result in
            switch result {
            case .success(let player):
                self.playerId = player.id
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func ready(completion: @escaping (Error?) -> ()) {
        guard let playerIdx = players.firstIndex(where: { $0.id == currentPlayer?.id }),
              let code = game?.id else { return }
        
        
        FirestoreManager.shared.ready(code: code, playerId: currentPlayer?.id) { error in
            if let error = error {
                completion(error)
            } else {
                self.players[playerIdx].isReady = true
                completion(nil)
            }
        }
    }
    
    func unreadyAllPlayers() {
        guard let code = code else { return }
        FirestoreManager.shared.unreadyAllPlayers(code: code, players: self.players)
    }
    
    func startGame(completion: @escaping (Error?) -> ()) {
        setGameStatus(.started, completion: completion)
        
        // Set all users back to unready
        guard let code = game?.id else { return }
        FirestoreManager.shared.unreadyAllPlayers(code: code, players: players)
    }
        
    func nextRound(completion: @escaping (Error?)->()) {
        if currentRound + 1 < questions.count {
            // Go to next question
            currentRound += 1
            completion(nil)
        } else {
            // No question available
            if currentPlayer?.isCreator == true {
                finishGame(completion: completion)
            }
        }
    }
    
    func setVotingCompleted(completion: @escaping (Error?) -> ()) {
        setGameStatus(.votingCompleted, completion: completion)
    }
    
    func setReadyForNextRound(completion: @escaping (Error?) -> ()) {
        setGameStatus(.readyForNextRound, completion: completion)
    }
    
    func setGameStatus(_ status: GameStatus, completion: @escaping (Error?) -> ()) {
        guard let code = game?.id else { return }
                
        FirestoreManager.shared.setGameStatus(code: code, status: status) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    func finishGame(completion: @escaping (Error?) -> ()) {
        setGameStatus(.finished, completion: completion)
    }
    
    func answerQuestion(_ answerText: String?, completion: @escaping (Error?)->()) {
        guard let questionId = question?.id,
              let playerId = currentPlayer?.id,
              let code = code else { return }
        
        let answer = Answer(questionId: questionId, playerId: playerId, text: answerText)
        FirestoreManager.shared.saveAnswerForQuestion(code: code, answer: answer, completion: completion)
    }
   
    func voteForAnswer(_ answer: Answer, completion: @escaping (Error?)->()) {
        guard  let code = code else { return }
        FirestoreManager.shared.voteForAnswer(code: code, answer: answer, completion: completion)
    }
    
}
