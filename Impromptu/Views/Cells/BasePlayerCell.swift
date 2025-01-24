//
//  GameOverCell.swift
//  TPG
//
//  Created by Shane Brelesky on 1/23/25.
//

import Foundation
import UIKit
import SnapKit

class BasePlayerCell: UITableViewCell {
    
    static let identifier = "playerCell"
    
    let rankLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.secondary(weight: .light).font.withDynamicSize(14.0)
        l.textColor = Theme.Colors.subheading
        l.text = ""
        l.textAlignment = .center
        
        return l
    }()
    
    let nameLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.secondary(weight: .demiBold).font.withDynamicSize(20.0)
        l.textColor = .white
        l.text = ""
        l.textAlignment = .left
        
        return l
    }()
    
    let pointsLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.secondary(weight: .bold).font.withDynamicSize(28.0)
        l.textColor = .white
        l.text = ""
        l.textAlignment = .center
        
        return l
    }()
    
    var player: Player? {
        didSet {
            guard let player = player else { return }
            nameLabel.text = player.name
            pointsLabel.text = "\(player.points ?? 0)"
        }
    }
    
    let iconWidth = 20.0
    let horizontalSpacing = 20.0

    
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
        addSubview(rankLabel)
        addSubview(nameLabel)
        addSubview(pointsLabel)
        
        rankLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(horizontalSpacing).priority(.high)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(rankLabel.snp.trailing).offset(16).priority(.high)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(pointsLabel.snp.leading).offset(-horizontalSpacing)
        }
              
        pointsLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-horizontalSpacing)
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualToSuperview().multipliedBy(0.8)
        }
    }
}
