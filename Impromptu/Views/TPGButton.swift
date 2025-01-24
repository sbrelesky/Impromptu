//
//  TPGButton.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import UIKit
import SnapKit

class TPGButton: UIButton {
    
    let cornerRadius = 10.0
    let haptic = UIImpactFeedbackGenerator(style: .soft)
    var highlightColor: UIColor?
    var originalColor: UIColor?
    
    
    override var backgroundColor: UIColor? {
        didSet {
            guard let backgroundColor = backgroundColor, highlightColor == nil, originalColor == nil else { return }
            
            originalColor = backgroundColor
            highlightColor = backgroundColor.darken(by: 0.1)
        }
    }
    
    init(title: String, color: UIColor) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        backgroundColor = color
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        titleLabel?.font = Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(24.0)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = cornerRadius
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.backgroundColor = highlightColor
        self.haptic.impactOccurred()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.backgroundColor = originalColor
    }
    
    // MARK: - Private Methods
        
    private var constraintsAdded = false
    
    private func addConstraints() {
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(Constants.Heights.button).priority(.required)
            make.height.equalToSuperview().multipliedBy(0.08).priority(.medium)
            make.width.equalToSuperview().multipliedBy(Constants.WidthMultipliers.button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set up Auto Layout constraints
        if superview != nil && !constraintsAdded {
            addConstraints()
            constraintsAdded = true
            layoutIfNeeded()
            
            if backgroundColor == nil {
                backgroundColor = Theme.Colors.secondary
            }
            
            layer.shadowColor = UIColor.darkGray.cgColor
            layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
            layer.shadowOpacity = 0.3
            layer.shadowRadius = 2
        }
        
        layer.cornerRadius = bounds.height / 2
    }


}
