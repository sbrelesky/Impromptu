//
//  VoteBadge.swift
//  TPG
//
//  Created by Shane on 7/5/24.
//

import Foundation
import UIKit
import SnapKit

class VotesBadge: UIView {
    
    let valueLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(50.0)
        l.textColor = .white
        l.adjustsFontSizeToFitWidth = true
        l.textAlignment = .center

        return l
    }()
    
    let votesLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.main(weight: .medium).font.withSize(16.0)
        l.textColor = .white
        l.text = "votes"
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true

        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(valueLabel)
        addSubview(votesLabel)
        
        
        valueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-6)
            //make.bottom.equalTo(votesLabel.snp.top)
            make.width.height.lessThanOrEqualToSuperview().multipliedBy(0.6)
            //make.height.equalTo(valueLabel.snp.width)
        }
        
        let baselineOffset = valueLabel.font.ascender

        
        votesLabel.snp.makeConstraints { make in
            //make.top.equalTo(valueLabel.snp.top).offset(baselineOffset)
            make.top.equalTo(valueLabel.snp.bottom).offset(-4)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}
