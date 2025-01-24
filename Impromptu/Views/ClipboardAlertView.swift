//
//  ClipboardAlertView.swift
//  TPG
//
//  Created by Shane Brelesky on 7/20/24.
//

import Foundation
import UIKit
import SnapKit

class ClipboardAlertView: UIView {

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Copied to clipboard"
        label.textColor = Theme.Colors.text
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        layer.cornerRadius = 10
        addSubview(messageLabel)
       
        messageLabel.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    func show(in parentView: UIView) {
        parentView.addSubview(self)
        
        self.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(parentView)
            make.width.equalTo(200)
        }

        alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
                self.alpha = 0
            }) { _ in
                self.removeFromSuperview()
            }
        }
    }
}

