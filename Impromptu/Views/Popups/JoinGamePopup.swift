//
//  JoinGamePopup.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import UIKit
import SnapKit
import ViewAnimator

protocol JoinGamePopupDelegate: AnyObject {
    func entered(gameCode: String?, name: String, creating: Bool)
}

class JoinGamePopup: PopupController, UITextFieldDelegate {
   
    let gameCodeTextField: TPGTextField = {
        let tf = TPGTextField(frame: .zero)
        tf.setPlaceholder("Game Code")
        tf.keyboardType = .numberPad
        
        return tf
    }()
    
    let nameTextField: TPGTextField = {
        let tf = TPGTextField(frame: .zero)
        tf.setPlaceholder("Name")
        
        return tf
    }()

    lazy var enterButton: TPGButton = {
        let b = TPGButton(title: "Enter", color: Theme.Colors.primary)
        b.addTarget(self, action: #selector(enterPressed), for: .touchUpInside)
        return b
    }()
    
    let creating: Bool
    
    weak var delegate: JoinGamePopupDelegate?
    
    init(creating: Bool = false) {
        self.creating = creating
        super.init(text: creating ? "Start New Game" : "Join Game", nil)
        
        header.backgroundColor = creating ? Theme.Colors.secondary : Theme.Colors.tertiary
        enterButton.backgroundColor = creating ? Theme.Colors.secondary : Theme.Colors.tertiary
        gameCodeTextField.setColor(color: creating ? Theme.Colors.secondary : Theme.Colors.tertiary )
        nameTextField.setColor(color: creating ? Theme.Colors.secondary : Theme.Colors.tertiary )

        popupView.layer.borderWidth = 5
        popupView.layer.borderColor = creating ? Theme.Colors.secondary.cgColor : Theme.Colors.tertiary.cgColor
        
        nameTextField.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupAdditionalViews() {
        if !creating {
            popupView.addSubview(gameCodeTextField)
        }
        
        popupView.addSubview(nameTextField)
        popupView.addSubview(enterButton)
        
        popupView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(creating ? 0.35 : 0.5)
        }
         
        if !creating {
            gameCodeTextField.snp.makeConstraints { make in
                make.top.equalTo(header.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
                make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.textField)
                make.height.equalTo(!creating ? Constants.Heights.textField : 1)
                make.centerX.equalToSuperview()
            }
        }
        
        
        nameTextField.snp.makeConstraints { make in
            if !creating {
                make.top.equalTo(gameCodeTextField.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            } else {
                make.top.equalTo(header.snp.bottom).offset(Constants.Padding.Vertical.textFieldSpacing)
            }
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.textField)
            make.height.equalTo(Constants.Heights.textField)
            make.centerX.equalToSuperview()
        }
        
        enterButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
        
    }
    
 
    @objc func enterPressed() {
        guard let name = nameTextField.text else { return }
        
        if creating {
            dismissPopup()
            delegate?.entered(gameCode: nil, name: name, creating: creating)
        } else {
            guard let code = gameCodeTextField.text else { return }
            dismissPopup()
            delegate?.entered(gameCode: code, name: name, creating: creating)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
