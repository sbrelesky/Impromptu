//
//  WinnerCardCell.swift
//  TPG
//
//  Created by Shane Brelesky on 1/23/25.
//

import Foundation
import UIKit

class WinnerCardCell: WinningResultCardCell {
    
    var player: Player? {
        didSet {
            guard let player = player else { return }
            answerTextView.text = player.name
            votesBadge.valueLabel.text = "\(player.points)"
            votesBadge.votesLabel.text = "points"
            answerTextView.textAlignment = .center
            answerTextView.font = Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(60.0)
        }
    }
}

