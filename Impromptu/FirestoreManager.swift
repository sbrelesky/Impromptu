//
//  FirestoreManager.swift
//  TPG
//
//  Created by Shane on 5/20/24.
//

import Foundation
import FirebaseFirestore


enum CustomError: Error {
    case invalidData, unknown, noData
}

struct FirestoreManager {
        
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
}

// MARK: - Fetch Methods

extension FirestoreManager {
    
    func fetchGame(code: String, completion: @escaping (Result<Game, Error>)->()) {
        db.collection(Constants.FirestoreKeys.gamesCollection).document(code).getDocument(as: Game.self, completion: completion)
    }
    
    func fetchPlayers(code: String, completion: @escaping (Result<[Player], Error>)->()) {
        db.collection(Constants.FirestoreKeys.gamesCollection).document(code).collection(Constants.FirestoreKeys.playersSubCollection).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let players = querySnapshot?.documents.compactMap({ try? $0.data(as: Player.self )}) ?? []
                completion(.success(players))
            }
        }
    }
    
    func fetchQuestions(code: String, completion: @escaping (Result<[Question], Error>)->()) {
        db.collection(Constants.FirestoreKeys.gamesCollection).document(code).collection(Constants.FirestoreKeys.questionsSubCollection).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let questions = querySnapshot?.documents.compactMap({ try? $0.data(as: Question.self )}) ?? []
                completion(.success(questions))
            }
        }
    }
    
    func fetchAnswers(code: String, questionId: String, completion: @escaping (Result<[Answer], Error>)->()) {
        db.collection(Constants.FirestoreKeys.gamesCollection).document(code)
            .collection(Constants.FirestoreKeys.answersSubCollection)
            .whereField("questionId", isEqualTo: questionId)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let answers = querySnapshot?.documents.compactMap({ try? $0.data(as: Answer.self )}) ?? []
                completion(.success(answers))
            }
        }
    }
    
    func observeGame(code: String, completion: @escaping (Result<Game, Error>)->()) -> ListenerRegistration {
        return db.collection(Constants.FirestoreKeys.gamesCollection).document(code).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                do {
                    guard let snapshot = snapshot else {
                        completion(.failure(CustomError.noData))
                        return
                    }
                    
                    let game = try snapshot.data(as: Game.self)
                    completion(.success(game))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func observePlayers(code: String, completion: @escaping (Result<[Player], Error>)->()) -> ListenerRegistration {
        return db.collection(Constants.FirestoreKeys.gamesCollection).document(code).collection(Constants.FirestoreKeys.playersSubCollection).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else {
                    completion(.failure(CustomError.noData))
                    return
                }
                
                do {
                    let players = try snapshot.documents.compactMap({ try $0.data(as: Player.self) })
                    completion(.success(players))
                } catch (let error) {
                    completion(.failure(error))
                }
                
//                snapshot.documentChanges.forEach { change in
//                    do {
//                        let player = try change.document.data(as: Player.self)
//                        completion(.success((change.type, player)))
//                        
//                    } catch let error {
//                        completion(.failure(error))
//                    }
//                }
            }
        }
    }
    
    
    func observeAnswers(with code: String, for questionId: String, completion: @escaping (Result<[Answer], Error>)->()) -> ListenerRegistration {
        return db.collection(Constants.FirestoreKeys.gamesCollection).document(code)
            .collection(Constants.FirestoreKeys.answersSubCollection)
            .whereField("questionId", isEqualTo: questionId)
            .addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else {
                    completion(.failure(CustomError.noData))
                    return
                }
                
                do {
                    let answers = try snapshot.documents.compactMap({ try $0.data(as: Answer.self) })
                    completion(.success(answers))
                } catch let error {
                    completion(.failure(error))
                }
            
            }
        }
    }
}

// MARK: - Game Setup Methods

extension FirestoreManager {
    
    func createGame(name: String) async throws -> GameCode {
        let gameCode = generateGameCode()
        
        let data = [
            "id": gameCode,
            "dateCreated": Timestamp(date: Date()),
            "status": 0
        ] as [String : Any]
        
        
        try await db.collection(Constants.FirestoreKeys.gamesCollection).document(gameCode).setData(data)
        return gameCode
    }
    
    func createGame(name: String, completion: @escaping (Result<String, Error>) -> ()) {
        let gameCode = generateGameCode()
        
        let data = [
            "id": gameCode,
            "dateCreated": Timestamp(date: Date()),
            "status": 0
        ] as [String : Any]
        
        
        db.collection(Constants.FirestoreKeys.gamesCollection).document(gameCode).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(gameCode))
            }
        }
    }
    
    func joinGame(code: String, name: String, isCreator: Bool = false, completion: @escaping (Result<Player,Error>)->()) {
        let playerData = [
            "name": name,
            "isCreator": isCreator,
            "isReady": false,
            "points": 0
        ] as [String : Any]
        
        let playerRef = db.collection(Constants.FirestoreKeys.gamesCollection).document(code).collection(Constants.FirestoreKeys.playersSubCollection).document()
        
        playerRef.setData(playerData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                playerRef.getDocument(as: Player.self, completion: completion)
            }
        }
    }
    
    func setQuestionsFoGame(code: String, completion: @escaping (Result<[Question], Error>)->()) {
        getRandomQuestionIdsForGame { ids in
            guard ids.count > 0 else {
                completion(.failure(CustomError.noData))
                return
            }
            
            db.collection(Constants.FirestoreKeys.questionsCollection)
                .whereField(FieldPath.documentID(), in: ids).getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        
                        do {
                            let questions = try snapshot?.documents.compactMap({ try $0.data(as: Question.self) }) ?? []
                            
                            self.batchUpdateQuestions(questions, completion: completion)
                            
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
        }
    }
    
    private func batchUpdateQuestions(_ questions: [Question], completion: @escaping (Result<[Question], Error>)->()) {
        let batch = db.batch()
        questions.forEach { question in
            if let id = question.id {
                
                let ref = db.collection(Constants.FirestoreKeys.gamesCollection)
                    .document(code)
                    .collection(Constants.FirestoreKeys.questionsSubCollection)
                    .document(id)
                
                do {
                   try batch.setData(from: question, forDocument: ref)
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(questions))
            }
        }
    }
    
    private func getRandomQuestionIdsForGame(completion: @escaping ([String]) -> Void) {
        // Go pull questions and set them on the game
        db.collection(Constants.FirestoreKeys.questionsCollection).getDocuments { querySnapshot, error in
            if let error = error {
                completion([])
            } else {
                guard let documents = querySnapshot?.documents else {
                    completion([])
                    return
                }
                
                let shuffledDocuments = documents.shuffled()
                let selectedDocuments = Array(shuffledDocuments.prefix(Constants.numberOfQuestionsPerGame))
                let selectedDocumentIds: [String] = selectedDocuments.compactMap({ String($0.documentID) })
                
                completion(selectedDocumentIds)
            }
        }
    }
}

// MARK: - Play Game Methods

extension FirestoreManager {
    
    func ready(code: String, playerId: String?, completion: @escaping (Error?)->()) {
        guard let playerId = playerId else { return }
        
        db.collection(Constants.FirestoreKeys.gamesCollection).document(code)
            .collection(Constants.FirestoreKeys.playersSubCollection)
            .document(playerId)
            .updateData(["isReady":true], completion: completion)
    }
    
    func unreadyAllPlayers(code: String, players: [Player]) {
        
        let playerIds = players.compactMap({ $0.id })
        playerIds.forEach { id in
            db.collection(Constants.FirestoreKeys.gamesCollection).document(code)
                .collection(Constants.FirestoreKeys.playersSubCollection)
                .document(id)
                .updateData(["isReady": false])
        }        
    }
    
    func setGameStatus(code: String, status: GameStatus, completion: @escaping (Error?)->()) {
        db.collection(Constants.FirestoreKeys.gamesCollection).document(code).updateData(["status": status.rawValue])
    }
    
    func saveAnswerForQuestion(code: String, answer: Answer, completion: @escaping (Error?)->()) {
        do {
           try db.collection(Constants.FirestoreKeys.gamesCollection).document(code).collection("answers").addDocument(from: answer, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    func voteForAnswer(code: String, answer: Answer, completion: @escaping (Error?)->()) {
        guard let answerId = answer.id else { return }
        let playerId = answer.playerId
        
        db.collection(Constants.FirestoreKeys.gamesCollection).document(code)
            .collection("answers")
            .document(answerId)
            .updateData(["votes": FieldValue.increment(Int64(1))], completion: completion)
     
        db.collection(Constants.FirestoreKeys.gamesCollection).document(code)
            .collection(Constants.FirestoreKeys.playersSubCollection)
            .document(playerId)
            .updateData(["points": FieldValue.increment(Int64(1))], completion: completion)
    }
    
    // MARK: - Helper Methods
    
    func generateGameCode() -> String {
        let length = 5
        let digits = "0123456789"
        return String((0..<length).map { _ in digits.randomElement()! })
    }
}
