//
//  TPGTextField.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import UIKit
import SnapKit

class TPGTextField: PaddedTextField {
    
    // MARK: - Properties

    let floatingPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.Colors.placeholder
        label.adjustsFontSizeToFitWidth = true
        label.font = Theme.Fonts.Style.secondary(weight: .bold).font.withDynamicSize(Theme.Fonts.placeholderFontSize)

        return label
    }()

    private var floatingPlaceholderTopConstraint: Constraint?
    
    open var hidesPlacesholderWhenTypeing: Bool = false
    
    var color: UIColor

    // MARK: - Initialization

    init(frame: CGRect, color: UIColor = Theme.Colors.primary) {
        self.color = color

        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        color = Theme.Colors.primary
        super.init(coder: coder)
        
        commonInit()
    }

    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        
        setupStyle()
        
        // Set up floating placeholder label
        addSubview(floatingPlaceholderLabel)
        
        floatingPlaceholderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(padding.left)
            make.trailing.equalToSuperview().inset(padding.right)
            floatingPlaceholderTopConstraint = make.centerY.equalToSuperview().constraint // Will be updated later
        }
        
        // Listen for text field editing events
        addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        addTarget(self, action: #selector(focusTextField), for: .editingDidBegin)
        addTarget(self, action: #selector(endFocusTextField), for: .editingDidEnd)
    }
    
    private func setupStyle() {
        backgroundColor = .white
        font = Theme.Fonts.Style.secondary(weight: .bold).font.withDynamicSize(Theme.Fonts.placeholderFontSize)
        textColor = color
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = Theme.Colors.placeholder.cgColor
        tintColor = color
        autocapitalizationType = .none
        adjustsFontSizeToFitWidth = true
    }
    
    public func setColor(color: UIColor) {
        self.color = color
        setupStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update floating placeholder position
        updateFloatingPlaceholderPosition()
    }

    @objc func textFieldEditingChanged() {
        // Update floating placeholder position when text changes
        updateFloatingPlaceholderPosition()
    }
    
    @objc func focusTextField() {
        layer.borderColor = color.cgColor
    }
    
    @objc func endFocusTextField() {
        layer.borderColor = Theme.Colors.placeholder.cgColor
    }

    private func updateFloatingPlaceholderPosition() {
        if let text = text, !text.isEmpty {
            // If text field has text, move the floating placeholder above the text field
            floatingPlaceholderTopConstraint?.update(offset: -((bounds.height / 2) + floatingPlaceholderLabel.bounds.height / 2))
            floatingPlaceholderLabel.font = Theme.Fonts.Style.secondary(weight: .bold).font
            floatingPlaceholderLabel.textColor = color
            floatingPlaceholderLabel.isHidden = hidesPlacesholderWhenTypeing
            
        } else {
            // If text field is empty, move the floating placeholder back to its original position
            floatingPlaceholderTopConstraint?.update(offset: 0)
            floatingPlaceholderLabel.font = Theme.Fonts.Style.secondary(weight: .bold).font.withDynamicSize(Theme.Fonts.placeholderFontSize)
            floatingPlaceholderLabel.textColor = Theme.Colors.placeholder
            floatingPlaceholderLabel.isHidden = false
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }

    // MARK: - Public Methods

    func setPlaceholder(_ placeholder: String) {
        floatingPlaceholderLabel.text = placeholder
    }

    func showError() {
        layer.borderColor = Theme.Colors.primary.cgColor
        layer.borderWidth = 1.5
    }
}
