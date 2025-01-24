//
//  Popup.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation
import UIKit
import SnapKit
import ViewAnimator

class PopupController: BlurredBackgroundViewController {

    let popupView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 30
        v.clipsToBounds = true
        
        return v
    }()
    
    let header: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = Theme.Colors.primary
        
        return v
    }()
    
    let headerLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.main(weight: .bold).font.withSize(30.0)
        l.textColor = .white
        l.adjustsFontSizeToFitWidth = true
        
        return l
    }()
    
    
    lazy var dismissButton: UIButton = {
        let b = UIButton(type: .system)
        let largeTitle = UIImage.SymbolConfiguration(textStyle: .title3)
        let black = UIImage.SymbolConfiguration(weight: .black)
        let combined = largeTitle.applying(black)
        
        b.setImage(UIImage(systemName: "xmark", withConfiguration: combined)?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        
        return b
    }()
   
    let dismissHandler: (() -> Void)?
    let headerText: String?
    
    init(text: String? = nil, _ dismissCompletion: (() -> Void)?) {
        self.dismissHandler = dismissCompletion
        self.headerText = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // definesPresentationContext = true
        //view.backgroundColor = Theme.Colors.darkText.withAlphaComponent(0.85)
        setupForKeyboard()
        
        headerLabel.text = headerText

        setupViews()
        animate()
    }
    
    private func setupViews() {
        view.addSubview(popupView)
        popupView.addSubview(header)
        header.addSubview(dismissButton)
        header.addSubview(headerLabel)
        
        // Add constraints for popup view and dismiss button using SnapKit
        popupView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        header.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.15).priority(.medium)
            make.height.greaterThanOrEqualTo(60).priority(.required)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.6)
        }
                
        dismissButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        setupAdditionalViews()
    }
    
    func animate() {
        let fromAnimation = AnimationType.from(direction: .top, offset: 300)
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
       
        UIView.animate(views: [popupView],
                       animations: [fromAnimation],
                       duration: 0.8,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.3)
    }
    
    @objc func dismissPopup() {
        dismiss(animated: true, completion: dismissHandler)
    }
    
    // MARK: - Override this methods in subclasses
    func setupAdditionalViews() {
        fatalError("Subclasses must override setupAdditionalViews()")
    }
}

class BlurredBackgroundViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the method to add the blur effect
        addBlurEffect()
    }
    
    private func addBlurEffect() {
        // Create a blur effect
        let blurEffect = UIBlurEffect(style: .dark) // You can choose different styles: .dark, .light, .extraLight, .prominent, etc.
        
        // Create a visual effect view with the blur effect
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // Set the frame to cover the entire view
        blurEffectView.frame = self.view.bounds
        
        // Enable auto resizing mask to adapt to view size changes
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the blur effect view to the view hierarchy
        self.view.addSubview(blurEffectView)
        
        // Send the blur view to the back so it doesn't cover other UI elements
        self.view.sendSubviewToBack(blurEffectView)
    }
}
