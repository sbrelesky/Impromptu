//
//  Animations.swift
//  TPG
//
//  Created by Shane Brelesky on 7/20/24.
//

import UIKit
import ViewAnimator

extension UIView {
    func slam() {
        animate(animations: [AnimationType.zoom(scale: 2.0)], delay: 0.3)
    }
    
    func slide(from: Direction, offset: CGFloat) {
        animate(animations: [AnimationType.from(direction: from, offset: offset)], delay: 0.3)
    }
    
    func pulse(scale: CGFloat, duration: CGFloat = 1.0) {
        animate(animations: [AnimationType.zoom(scale: scale)], initialAlpha: 1.0, duration: duration, options: [.repeat, .autoreverse])
    }
}

extension UITableView {
    func animate(delay: CGFloat = 0.5) {
        animate(cells: visibleCells, delay: delay)
    }
    
    func animate(cells: [UITableViewCell], delay: CGFloat = 0.5) {
        UIView.animate(views: cells, animations: [AnimationType.from(direction: .bottom, offset: 60.0)], delay: delay)
    }
}


extension UICollectionView {
    func animate() {
        UIView.animate(views: visibleCells, animations: [AnimationType.from(direction: .bottom, offset: 60.0)], delay: 0.5)
    }
}

extension TPGButton {
    func animate(delay: CGFloat = 0.8) {
        animate(animations: [AnimationType.from(direction: .bottom, offset: 300)],
                delay: 0.8,
                     duration: 0.8,
                     usingSpringWithDamping: 0.6,
                     initialSpringVelocity: 0.3)
    }
}
