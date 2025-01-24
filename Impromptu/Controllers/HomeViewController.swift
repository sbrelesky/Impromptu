//
//  HomeViewController.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import UIKit
import SnapKit
import ViewAnimator

class HomeViewController: GameBaseController, GameManagerDelegate {
            
    let gameCodeStaticLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.secondary(weight: .demiBold).font
        l.textColor = Theme.Colors.subheading
        l.text = "Game Code"
        l.textAlignment = .center
        
        return l
    }()
    
    lazy var gameCodeLabel: UIButton = {
        let l = UIButton(frame: .zero)
        l.setTitleColor(Theme.Colors.text, for: .normal)
        l.setTitle(GameManager.shared.game?.id , for: .normal)
        l.titleLabel?.font = Theme.Fonts.Style.secondary(weight: .demiBold).font.withDynamicSize(Theme.Fonts.placeholderFontSize)
        l.backgroundColor = Theme.Colors.darkBackground
        l.layer.cornerRadius = 10.0
        l.layer.masksToBounds = true
        l.addTarget(self, action: #selector(didTapGameCode), for: .touchUpInside)
        
        return l
    }()
    
    let playersStaticLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.secondary(weight: .demiBold).font
        l.textColor = Theme.Colors.subheading
        l.text = "Players"
        l.textAlignment = .center
        
        return l
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.register(LeaderboardCell.self, forCellReuseIdentifier: "cell")
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
    
    lazy var startButton: TPGButton = {
        let b = TPGButton(title: "Start Game", color: Theme.Colors.secondary)
        b.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
        b.isHidden = !(GameManager.shared.currentPlayer?.isCreator ?? false)
        b.isEnabled = false
        b.layer.opacity = 0.3
        
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
    
    let haptic = UIImpactFeedbackGenerator(style: .soft)
    var didAnimate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Game"
        
        setupUI()
       
        GameManager.shared.observePlayers { [weak self] error in
            if let error = error {
                self?.presentError(error: error)
            } else {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    
                    if !(self?.didAnimate ?? false) {
                        self?.animate()
                    }
                }
            }
            
            if GameManager.shared.players.filter({ $0.id != GameManager.shared.currentPlayer?.id }).filter({ $0.isReady == false }).count == 0 {
                
                self?.startButton.isEnabled = true
                self?.startButton.layer.opacity = 1.0
            } else {
                self?.startButton.isEnabled = false
                self?.startButton.layer.opacity = 0.3
            }
        }
        
        GameManager.shared.observeGame { _ in }
        
        
        
//        let vc = RoundResultsController()
//        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerGameDidUpdateNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        GameManager.shared.detachPlayers()
        removeGameDidUpdateNotification()
    }
    
    func notifyGameDidUpdate() {
        if GameManager.shared.game?.status == .started {
            goToQuestionController()
        }
    }
    
    private func setupUI() {
        view.addSubview(gameCodeStaticLabel)
        view.addSubview(gameCodeLabel)
        view.addSubview(playersStaticLabel)
        view.addSubview(startButton)
        view.addSubview(readyButton)
        view.addSubview(tableView)
        view.addSubview(waitingLabel)
        
        readyButton.isHidden = (GameManager.shared.currentPlayer?.isCreator == true)
        startButton.isHidden = !readyButton.isHidden
        
        
        gameCodeStaticLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Padding.Vertical.bottomSpacing)
            make.centerX.equalToSuperview()
        }
        
        gameCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(gameCodeStaticLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(Constants.Heights.textField)
        }
        
        playersStaticLabel.snp.makeConstraints { make in
            make.top.equalTo(gameCodeLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
            make.top.equalTo(playersStaticLabel.snp.bottom)
            make.bottom.equalTo(readyButton.snp.top).offset(-Constants.Padding.Vertical.bottomSpacing)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Constants.Padding.Vertical.bottomSpacing)
            make.centerX.equalToSuperview()
        }
        
        readyButton.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(startButton)
        }
        
        waitingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(readyButton)
        }
    }
    
    private func animate() {
        didAnimate = true
        // Animate Game Code
        gameCodeLabel.animate(animations: [AnimationType.zoom(scale: 2.0)], delay: 0.3)
        
        // Animate tableView
        tableView.animate()
        
        // Animate Buttons
        readyButton.animate()
        startButton.animate()
//        UIView.animate(views: [readyButton, startButton],
//                       animations: [AnimationType.from(direction: .bottom, offset: 300)],
//                       delay: 0.8,
//                       duration: 0.8,
//                       usingSpringWithDamping: 0.6,
//                       initialSpringVelocity: 0.3)
    }
   
    
    // MARK: Button Targets - 
    
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
    
    @objc func startPressed() {
        GameManager.shared.startGame { error in
            if let error = error {
                self.presentError(error: error)
            }
        }
    }
    
    @objc func didTapGameCode() {
        haptic.impactOccurred()
        
        UIPasteboard.general.string = gameCodeLabel.titleLabel?.text
        let alert = ClipboardAlertView()
        alert.show(in: view)
    }
    
    private func goToQuestionController() {
        let vc = QuestionController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GameManager.shared.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LeaderboardCell
        cell.backgroundColor = .clear
        cell.player = GameManager.shared.players[indexPath.row]
        cell.rankLabel.text = "\(indexPath.row + 1)"
        cell.pointsLabel.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.bounds.height * 0.1
    }
}

