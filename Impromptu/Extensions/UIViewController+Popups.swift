//
//  UIViewController+Popups.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import UIKit

extension UIViewController {
    
    func presentError(error: Error, completion: (() -> Void)? = nil) {
        print(error)
        presentError(message: error.localizedDescription,  completion: completion)
    }
    
    func presentError(message: String, completion: (() -> Void)? = nil) {
        let haptic = UINotificationFeedbackGenerator()
        haptic.prepare()
        haptic.notificationOccurred(.error)
        
        let popup = ErrorPopup(message: message, completion: completion)
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.present(popup, animated: true)
    }
}
