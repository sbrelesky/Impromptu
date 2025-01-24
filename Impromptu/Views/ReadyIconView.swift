//
//  ReadyIconView.swift
//  TPG
//
//  Created by Shane on 7/5/24.
//

import Foundation
import UIKit
import SnapKit

class ReadyIconView: UIView {
    
    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.tertiary
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(circleView)
        addSubview(checkmarkImageView)
        
        circleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.center.equalTo(circleView)
            make.width.height.equalTo(circleView).multipliedBy(0.8)
        }
    }
    
    // Method to set circle color
    func setCircleColor(_ color: UIColor) {
        circleView.tintColor = color
    }
    
    // Method to set checkmark color
    func setCheckmarkColor(_ color: UIColor) {
        checkmarkImageView.tintColor = color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circleView.layer.cornerRadius = circleView.bounds.width / 2.0
    }
}
