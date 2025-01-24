//
//  ErrorPopup.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import UIKit
import SnapKit


class ErrorPopup: PopupController {

    let warningImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill")?.withRenderingMode(.alwaysTemplate).applyingSymbolConfiguration(.init(pointSize: 40.0)))
        iv.contentMode = .scaleToFill
        iv.tintColor = Theme.Colors.tertiary
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = .black
        l.textAlignment = .center
        l.text = "Something went wrong"
        l.font = Theme.Fonts.Style.secondary(weight: .bold).font.withDynamicSize(22.0)

        return l
    }()
    
    let messageLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = .black
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = Theme.Fonts.Style.secondary(weight: .regular).font

        return l
    }()


    lazy var cancelButton: TPGButton = {
        let b = TPGButton(title: "Dismiss", color: Theme.Colors.tertiary)
        b.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        return b
    }()


    init(message: String, completion: (() -> Void)?) {
        messageLabel.text = message
        super.init(completion)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupAdditionalViews() {
        
        popupView.addSubview(warningImageView)
        popupView.addSubview(titleLabel)
        popupView.addSubview(messageLabel)
        popupView.addSubview(cancelButton)
        
        warningImageView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(warningImageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(warningImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(cancelButton)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.lessThanOrEqualTo(cancelButton.snp.top).offset(-30)
            make.centerX.equalTo(titleLabel)
            make.width.equalTo(titleLabel)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
    }

    @objc func cancelPressed() {
        dismissPopup()
    }
}
