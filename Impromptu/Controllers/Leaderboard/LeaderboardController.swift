//
//  LeaderboardController.swift
//  TPG
//
//  Created by Shane on 7/5/24.
//

import Foundation
import UIKit
import SnapKit

class LeaderboardController: GameBaseController, GameManagerDelegate {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.register(LeaderboardCell.self, forCellReuseIdentifier: LeaderboardCell.identifier)
        tv.backgroundColor = Theme.Colors.darkBackground
        tv.layer.cornerRadius = 10.0
        tv.separatorColor = Theme.Colors.separatorColor

        return tv
    }()
    
    lazy var readyButton: TPGButton = {
        let b = TPGButton(title: "Ready", color: Theme.Colors.tertiary)
        b.addTarget(self, action: #selector(readyPressed), for: .touchUpInside)
        
        return b
    }()
    
    let waitingLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.main(weight: .regular).font
        l.text = "Waiting for other users to ready up"
        l.textColor = Theme.Colors.text
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        
        return l
    }()
    
    let nextQuestionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.main(weight: .medium).font.withDynamicSize(16.0)
        l.textColor = Theme.Colors.subheading
        l.text = "Next Question"
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true

        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Leaderboard"
      
        setupUI()
        
        GameManager.shared.observePlayers { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                
                if GameManager.shared.currentPlayer?.isCreator == true {
                    self.checkAllPlayersReady()
                }
                
                self.tableView.reloadData()
            }
        }
        
        notifyGameDidUpdate()
        registerGameDidUpdateNotification()
        animate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeGameDidUpdateNotification()
        GameManager.shared.detachPlayers()
    }
    
    func notifyGameDidUpdate() {
        handleGameStatus()
    }
    
    private func setupUI() {
        view.addSubview(readyButton)
        view.addSubview(tableView)
        view.addSubview(waitingLabel)
        view.addSubview(nextQuestionLabel)

        tableView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Padding.Vertical.bottomSpacing)
            make.bottom.equalTo(readyButton.snp.top).offset(-Constants.Padding.Vertical.bottomSpacing)
        }
        
        readyButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
        
        waitingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(readyButton)
        }
        
        nextQuestionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(readyButton.snp.top).offset(-5)
        }
    }
    
    private func animate() {
        tableView.animate()
        readyButton.animate()
        nextQuestionLabel.slide(from: .bottom, offset: 30)
    }
    
    @objc func readyPressed() {
        GameManager.shared.ready { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                self.readyButton.isHidden = true
                self.waitingLabel.isHidden = false
            }
        }
    }
    
    private func handleGameStatus() {
        switch GameManager.shared.game?.status {
        case .started:
            self.goToNextQuestionController()
        case .readyForNextRound:
            self.prepareForNextRound()
        case .finished:
            self.goToGameOver()
        default:
            break
        }
    }
    
    private func checkAllPlayersReady() {
        if GameManager.shared.players.filter({ !($0.isReady ?? false) }).count == 0 {
            // All players are ready
            // Set the status to readyForNextRound
            GameManager.shared.setReadyForNextRound { error in
                if let error = error {
                    self.presentError(error: error)
                }
            }
        }
    }
    
    private func prepareForNextRound() {
        GameManager.shared.nextRound { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                if GameManager.shared.currentPlayer?.isCreator == true {
                    GameManager.shared.setGameStatus(.started) { error in
                        if let error = error {
                            self.presentError(error: error)
                        }
                    }
                }
            }
        }
    }
    
    private func goToNextQuestionController() {
        if let viewControllers = self.navigationController?.viewControllers {
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 4], animated: false)
        }
    }
    
    private func goToGameOver() {
        let vc = GameOverController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LeaderboardController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GameManager.shared.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardCell.identifier, for: indexPath) as! LeaderboardCell
        let player = GameManager.shared.players[indexPath.row]
            
        cell.player = player
        cell.rankLabel.text = "\(indexPath.row + 1)"
        
        if player.isReady == true {
            cell.setReady()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

