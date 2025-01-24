//
//  AnswerContainer.swift
//  TPG
//
//  Created by Shane on 7/8/24.
//

import Foundation
import UIKit
import SnapKit

protocol AnswerContainerDelegate: AnyObject {
    func send(text: String?)
}

class AnswerContainerView: UIView, UITextViewDelegate {
    
    let padding = 8.0
    
    let answerTextField: PaddedTextView = {
        let tf = PaddedTextView(padding: .init(top: 20.0, left: 10.0, bottom: 8.0, right: 10.0))
        tf.font = Theme.Fonts.Style.main(weight: .medium).font.withSize(18.0)
        tf.tintColor = Theme.Colors.text
        tf.textColor = Theme.Colors.text
        tf.backgroundColor = Theme.Colors.primary
        tf.text = Constants.Text.answerContainerText
        tf.isScrollEnabled = false
        tf.layer.cornerRadius = 5.0
        tf.returnKeyType = .send
        
        return tf
    }()
    
    lazy var sendButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.setTitle("Send", for: .normal)
        b.setTitleColor(Theme.Colors.text, for: .normal)
        b.addTarget(self, action: #selector(send), for: .touchUpInside)
        b.titleLabel?.font = Theme.Fonts.Style.main(weight: .demiBold).font.withSize(20.0)
        return b
    }()
    
    weak var delegate: AnswerContainerDelegate?
    
    var textFieldHeight: NSLayoutConstraint?
    
    var isPlaceholder = true
    
    var didLayoutTextField = false
    
    private var isOversized = false {
        didSet {
            guard oldValue != isOversized else {
                return
            }
            
            answerTextField.isScrollEnabled = isOversized
            answerTextField.setNeedsUpdateConstraints()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Colors.darkBackground
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 20.0
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(answerTextField)
        addSubview(sendButton)
        
        answerTextField.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.7).priority(.required)
            make.leading.equalToSuperview().offset(padding)
            make.centerY.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-padding)
            make.centerY.equalToSuperview()
            make.height.equalTo(answerTextField)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        
        textFieldHeight = answerTextField.heightAnchor.constraint(equalToConstant: Constants.Heights.textField)
        textFieldHeight?.isActive = true
        
        answerTextField.delegate = self
    }
    
    @objc private func send() {
        delegate?.send(text: answerTextField.text)
        answerTextField.resignFirstResponder()
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isPlaceholder {
            answerTextField.text = nil
            answerTextField.tintColor = Theme.Colors.text
            isPlaceholder = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if answerTextField.text.isEmpty {
            answerTextField.text = Constants.Text.answerContainerText
            answerTextField.textColor = Theme.Colors.placeholder
            isPlaceholder = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//            send()
//            return false
//        }
        return true
    }
    
    func adjustTextViewHeight() {
        // let fixedWidth = answerTextField.bounds.size.width
        answerTextField.sizeToFit()
        
        if answerTextField.contentSize.height >= bounds.height * 0.85 {
            answerTextField.isScrollEnabled = true
        } else {
            answerTextField.isScrollEnabled = false
            textFieldHeight?.constant = max(answerTextField.contentSize.height, Constants.Heights.textField)
        }
        
        layoutSubviews()
    }
    
    func reset() {
        answerTextField.text = Constants.Text.answerContainerText
        isPlaceholder = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !didLayoutTextField && answerTextField.bounds.height > 0.0 {
            didLayoutTextField = true
            answerTextField.layer.cornerRadius = answerTextField.bounds.height / 2
        }
    }
}
