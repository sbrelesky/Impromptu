//
//  VotingCell.swift
//  TPG
//
//  Created by Shane on 7/5/24.
//

import Foundation
import UIKit
import SnapKit

protocol VotingCellDelegate: AnyObject {
    func voted(answer: Answer)
}

class VotingCell: UICollectionViewCell {
    
    let card: ShadowCard = {
        let v = ShadowCard(cornerRadius: 40.0)
        v.backgroundColor = Theme.Colors.text
        v.layer.cornerRadius = 40.0
//        v.layer.borderWidth = 3
//        v.layer.borderColor = Theme.Colors.tertiary.cgColor
        
        return v
    }()
    
    let answerTextView: UILabel = {
        let tv = UILabel(frame: .zero)
        tv.font = Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(30.0)
        tv.textColor = Theme.Colors.darkText
        tv.backgroundColor = .clear
        tv.adjustsFontSizeToFitWidth = true
        tv.numberOfLines = 0
        tv.minimumScaleFactor = 0.4
        
        return tv
    }()
    
    var answer: Answer? {
        didSet {
            guard let answer = answer else { return }
            
            if let question = GameManager.shared.question, question.text.contains(Constants.answerSubstitutionKey) {
                let attributedString = createAttributedString(from: question.text, replacing: Constants.answerSubstitutionKey, with: answer.text ?? "")
                answerTextView.attributedText = attributedString
                
            } else {
                answerTextView.text = answer.text
                answerTextView.textColor = Theme.Colors.tertiary
            }
        }
    }
    private var shadowLayer: CAShapeLayer!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(card)
        card.addSubview(answerTextView)
        
        card.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.85)
            make.width.equalToSuperview().multipliedBy(0.875)
            make.centerX.centerY.equalToSuperview()
        }
        
        answerTextView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
//            make.top.equalToSuperview().offset(20)
//            make.width.equalToSuperview().multipliedBy(0.9)
//            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    
    
    func createAttributedString(from original: String, replacing placeholder: String, with replacement: String) -> NSAttributedString {
        
        // Split the replacements by commas
        let replacementArray = replacement.components(separatedBy: ",")
          
        // Create a mutable attributed string from the original string
        let attributedString = NSMutableAttributedString(string: original)
        attributedString.addAttribute(.font, value: Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(30.0), range: NSRange(location: 0, length: attributedString.length))

        // Iterate through the replacementArray and replace the placeholders one by one
        var currentIndex = 0
        while let range = attributedString.string.range(of: placeholder) {
            guard currentIndex < replacementArray.count else { break }
              
            // Get the replacement string for the current placeholder
            let replacement = replacementArray[currentIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            let nsRange = NSRange(range, in: attributedString.string)
              
            // Replace the placeholder with the replacement string
            attributedString.replaceCharacters(in: nsRange, with: replacement)
              
            // Apply attributes to the replacement string
            let newRange = NSRange(location: nsRange.location, length: replacement.count)
            attributedString.addAttribute(.foregroundColor, value: Theme.Colors.tertiary, range: newRange)
            attributedString.addAttribute(.font, value: Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(30.0), range: newRange)
              
            currentIndex += 1
        }
          
        return attributedString
    }
    
   
    override func prepareForReuse() {
        super.prepareForReuse()
        
        answerTextView.text = ""
    }
}


class ShadowCard: UIView {
    private var shadowLayer: CAShapeLayer!

    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        
        backgroundColor = Theme.Colors.text
        layer.cornerRadius = cornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 3.0)
            shadowLayer.shadowOpacity = 0.65
            shadowLayer.shadowRadius = 5

            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }

}
