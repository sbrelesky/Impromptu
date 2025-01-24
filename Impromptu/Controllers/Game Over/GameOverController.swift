//
//  GameOverController.swift
//  TPG
//
//  Created by Shane on 7/9/24.
//

import Foundation
import UIKit
import SnapKit

class GameOverController: GameBaseController {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.register(BasePlayerCell.self, forCellReuseIdentifier: BasePlayerCell.identifier)
        tv.register(WinnerCardCell.self, forCellReuseIdentifier: "winningCell")
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        
        return tv
    }()
    
    
    lazy var doneButton: TPGButton = {
        let b = TPGButton(title: "Done", color: Theme.Colors.tertiary)
        b.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
        
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Game Over"
        view.backgroundColor = Theme.Colors.primary
        
        setupUI()
    }
    
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Padding.Vertical.bottomSpacing)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.bottom.equalTo(doneButton.snp.top).offset(-20)
        }
        
        doneButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: Button Targets -
    
    @objc func donePressed() {
        GameManager.shared.clean()
        navigationController?.dismiss(animated: true)
    }
}


extension GameOverController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : GameManager.shared.players.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "winningCell", for: indexPath) as? WinnerCardCell {
                cell.player = GameManager.shared.players[0]
                return cell
            }
            
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: BasePlayerCell.identifier, for: indexPath) as? BasePlayerCell {
                cell.player = GameManager.shared.players[indexPath.row + 1]
                let formatter = NumberFormatter()
                formatter.numberStyle = .ordinal
                cell.rankLabel.text = formatter.string(from: NSNumber(integerLiteral: indexPath.row + 2))
                return cell
            }
        }
               
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 220 : 60
    }
    
}
