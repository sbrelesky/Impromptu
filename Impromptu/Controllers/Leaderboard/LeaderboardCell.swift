//
//  LeaderboardCelll.swift
//  TPG
//
//  Created by Shane on 7/5/24.
//

import Foundation
import UIKit
import SnapKit

class LeaderboardCell: BasePlayerCell {
    
    let readyIcon: ReadyIconView = {
        let iv = ReadyIconView(frame: .zero)
        iv.isHidden = true
        
        return iv
    }()
    
    override var player: Player? {
        didSet {
            super.player = player
            guard let player = player else { return }

            if player.isReady == true {
                setReady()
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(readyIcon)
    
        readyIcon.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(rankLabel)
            make.width.height.equalTo(24)
        }
    }
    
    public func setReady() {
        UIView.animate(withDuration: 0.6) {
            self.readyIcon.isHidden = false
            self.rankLabel.isHidden = true
        }
    }
}

