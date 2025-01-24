//
//  UIViewController+Keyboard.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import UIKit

extension UIViewController {
        
    func setupForKeyboard() {
        hidesKeyboardOnTap()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
       NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(sender: NSNotification) {
        
        if let focusedTextfield = findActiveTextField(in: view),
            let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let textFieldFrame = view.convert(focusedTextfield.frame, from: focusedTextfield.superview)
        
            
            if textFieldFrame.maxY > (view.frame.height - keyboardHeight) {
                UIView.animate(withDuration: 0.4, delay: 0) {
                    // Textfield needs to move up
                    self.view.frame.origin.y = -(textFieldFrame.maxY - (self.view.frame.height - keyboardHeight) + 40)
                }
            }
        }
    }

    @objc private func keyboardWillHide(sender: NSNotification) {
        UIView.animate(withDuration: 0.4, delay: 0) {
            self.view.frame.origin.y = 0
        }
    }
    
    func hidesKeyboardOnTap() {
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        hidesKeyboardOnTap { gesture, touch in
            if touch.view is UITextField || touch.view is UIButton {
                return false
            }
            
            return true
        }
    }
    
    func hidesKeyboardOnTap(shouldReceiveTouch: ((UIGestureRecognizer, UITouch) -> Bool)? = nil) {
        let tap = CustomTapGestureRecognizer(target: self, action: #selector(dismissMyKeyboard))
        tap.cancelsTouchesInView = false
        tap.shouldReceiveTouch = shouldReceiveTouch
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissMyKeyboard(){
       //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
       //In short- Dismiss the active keyboard.
       view.endEditing(true)
    }

    
    private func findActiveTextField(in view: UIView) -> UITextField? {
        for subview in view.subviews {
            if let textField = subview as? UITextField, textField.isFirstResponder {
                return textField
            }
            
            if let nestedTextField = findActiveTextField(in: subview) {
                return nestedTextField
            }
        }
        return nil
    }
}

class CustomTapGestureRecognizer: UITapGestureRecognizer, UIGestureRecognizerDelegate {
    var shouldReceiveTouch: ((UIGestureRecognizer, UITouch) -> Bool)?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        self.delegate = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return shouldReceiveTouch?(gestureRecognizer, touch) ?? true
    }
}
