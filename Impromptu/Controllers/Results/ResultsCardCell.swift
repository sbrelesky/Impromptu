//
//  ResultsCardCell.swift
//  TPG
//
//  Created by Shane on 7/5/24.
//

import Foundation
import UIKit
import SnapKit


class ResultsCardCell: UITableViewCell {
    
    let card: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = Theme.Colors.darkBackground
        v.layer.cornerRadius = 20

        return v
    }()
    
    let votesBadge: VotesBadge = {
        let v = VotesBadge(frame: .zero)
        v.backgroundColor = Theme.Colors.darkBackground
        v.layer.borderWidth = 3
        v.layer.borderColor = Theme.Colors.primary.cgColor
        
        return v
    }()
    
    let answerTextView: UILabel = {
        let tv = UILabel(frame: .zero)
        tv.font = Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(24.0)
        tv.textColor = Theme.Colors.text
        tv.numberOfLines = 0
        tv.backgroundColor = .clear
        tv.adjustsFontSizeToFitWidth = true
        
        return tv
    }()
    
    var answer: Answer? {
        didSet {
            guard let answer = answer else { return }
            votesBadge.valueLabel.text = "\(answer.votes)"
            answerTextView.text = answer.text
        }
    }
    
    let spacing = 10.0
    
    public var badgeHeightMultiplier = 0.52
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(card)
        addSubview(votesBadge)
        card.addSubview(answerTextView)
        
        votesBadge.votesLabel.font = Theme.Fonts.Style.main(weight: .medium).font.withDynamicSize(10.0)
        
        votesBadge.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(badgeHeightMultiplier)
            make.width.equalTo(votesBadge.snp.height)
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }
        
        card.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.95)
            //make.width.equalToSuperview().multipliedBy((1.0 - badgeWidthMultiplier) - 0.04)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(votesBadge.snp.centerX)
        }
        
        answerTextView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.9)
            make.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(votesBadge.snp.trailing).offset(8)
        }
        
        bringSubviewToFront(votesBadge)
    }
}

class WinningResultCardCell: ResultsCardCell {
    
    override var badgeHeightMultiplier: Double {
        get {
            return 0.4
        }
        set {}
    }
    
    let playerNameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.Style.main(weight: .medium).font.withDynamicSize(18.0)
        label.textColor = Theme.Colors.subheading
        
        return label
    }()
    
    override var answer: Answer? {
        didSet {
            guard let answer = answer else { return }
            votesBadge.valueLabel.text = "\(answer.votes)"
            answerTextView.text = answer.text
            
            if let player = GameManager.shared.players.first(where: { $0.id == answer.playerId}) {
                answerTextView.text = (answerTextView.text ?? "")
                playerNameLabel.text = player.name
            }
            
            slam()
        }
    }
    
    override func setupViews() {
        addSubview(card)
        addSubview(votesBadge)
        card.addSubview(answerTextView)
        card.addSubview(playerNameLabel)
        
        votesBadge.backgroundColor = Theme.Colors.tertiary
        votesBadge.valueLabel.font = Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(180.0)
        votesBadge.votesLabel.font = Theme.Fonts.Style.main(weight: .medium).font.withDynamicSize(16.0)

        votesBadge.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(badgeHeightMultiplier)
            make.width.equalTo(votesBadge.snp.height)
            make.top.centerX.equalToSuperview()
        }
        
        card.snp.makeConstraints { make in
            make.top.equalTo(votesBadge.snp.centerY)
            make.bottom.equalToSuperview().inset(spacing)
            make.leading.trailing.equalToSuperview().inset(spacing)
        }
        
        answerTextView.snp.makeConstraints { make in
            make.top.equalTo(votesBadge.snp.bottom).offset(spacing)
            make.bottom.equalTo(playerNameLabel.snp.top).offset(-spacing)
            make.leading.trailing.equalToSuperview().inset(spacing)
        }
        
        playerNameLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(spacing)
        }
    }
}

