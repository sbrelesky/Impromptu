//
//  RoundResultsController.swift
//  TPG
//
//  Created by Shane on 7/5/24.
//

import Foundation
import UIKit
import SnapKit


class RoundResultsController: GameBaseController {
    
    var answers: [Answer] = []
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.register(ResultsCardCell.self, forCellReuseIdentifier: "cell")
        tv.register(WinningResultCardCell.self, forCellReuseIdentifier: "winningCell")
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        
        return tv
    }()
    
    lazy var nextButton: TPGButton = {
        let b = TPGButton(title: "Next", color: Theme.Colors.tertiary)
        b.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        return b
    }()
    
    
    let nextQuestionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.main(weight: .medium).font.withDynamicSize(16.0)
        l.textColor = Theme.Colors.subheading
        l.text = "Next Question"
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.isHidden = true

        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Results"
        
        setupUI()
        
        GameManager.shared.fetchAnswers { [weak self] result in
            switch result {
            case .success(let answers):
                self?.answers = answers.sorted(by: { $0.votes > $1.votes})
                self?.tableView.reloadData()
                self?.animate()
            case .failure(let error):
                self?.presentError(error: error)
            }
        }
        
        GameManager.shared.unreadyAllPlayers()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(nextButton)
        view.addSubview(nextQuestionLabel)
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(nextQuestionLabel.snp.top).offset(-10)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
        
        nextQuestionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top)
        }
    }
    
    private func animate() {
        tableView.animate(cells: tableView.visibleCells(in: 1), delay: 0.8)
        nextButton.animate(delay: 1.5)
    }
    
    @objc func nextPressed() {
        let vc = LeaderboardController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RoundResultsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (answers.isEmpty ? 0 : 1) : answers.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "winningCell", for: indexPath) as? WinningResultCardCell {
                if answers.indices.contains(0) {
                    cell.answer = answers[0]
                }
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ResultsCardCell {
                if answers.indices.contains(indexPath.row + 1) {
                    cell.answer = answers[indexPath.row + 1]
                }
                return cell
            }
        }
        
//        let pointSize = indexPath.section  == 0 ? 24.0 : 20.0
//        cell.answerTextView.font = Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(pointSize)
        // cell.votesBadge.votesLabel.isHidden = (indexPath.section != 0)
       
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 320 : 100
    }
    
}


