//
//  PaddedTextView.swift
//  TPG
//
//  Created by Shane on 5/22/24.
//

import Foundation
import UIKit

class PaddedTextView: UITextView {
    
    // Custom padding properties
    var padding: UIEdgeInsets {
        didSet {
            self.textContainerInset = padding
        }
    }
    
    // Initializer with padding parameter
    init(padding: UIEdgeInsets) {
        self.padding = padding
        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = padding
    }
    
    required init?(coder: NSCoder) {
        self.padding = .zero
        super.init(coder: coder)
        self.textContainerInset = padding
    }
}


class PaddedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    // MARK: - Placeholder Handling

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
