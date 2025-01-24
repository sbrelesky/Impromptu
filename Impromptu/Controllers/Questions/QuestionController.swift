//
//  QuestionController.swift
//  TPG
//
//  Created by Shane on 5/22/24.
//

import Foundation
import UIKit
import SnapKit


class QuestionController: GameBaseController {
    
    let questionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.secondary(weight: .demiBold).font.withSize(18.0)
        l.textColor = Theme.Colors.subheading
        l.text = "Question 1"
        l.textAlignment = .left
        
        return l
    }()
    
    let timerLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.secondary(weight: .demiBold).font.withSize(30.0)
        l.textColor = Theme.Colors.text
        l.text = "\(Constants.questionTimerSeconds)"
        l.textAlignment = .right
        
        return l
    }()
    
    let questionTextView: PaddedTextView = {
        let tv = PaddedTextView(padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        tv.font = Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(30.0)
        tv.textColor = Theme.Colors.text
        tv.backgroundColor = .clear
        tv.layer.cornerRadius = 10.0
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.isUserInteractionEnabled = false
        
        return tv
    }()
    
    let answerContainerView: AnswerContainerView = {
        let v = AnswerContainerView(frame: .zero)
        return v
    }()
 
    var timer: Timer?
    
    var timerCounter = Constants.questionTimerSeconds
        
    var containerBottomConstraint: Constraint?
    
    var answered = false
  
    
    // MARK: Lifecycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hidesKeyboardOnTap()
        setupUI()
        animate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        questionTextView.text = GameManager.shared.question?.text
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        timerCounter = Constants.questionTimerSeconds
        answered = false
        
        startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        questionTextView.text = ""
        answerContainerView.reset()
    }
    
    // MARK: UI Methods -
    
    private func setupUI() {
        view.addSubview(questionLabel)
        view.addSubview(timerLabel)
        view.addSubview(questionTextView)
        view.addSubview(answerContainerView)
        
        questionLabel.text = "Question \(GameManager.shared.currentRound + 1)"
        
        answerContainerView.delegate = self
        
        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(questionTextView)
        }
        
        questionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(timerLabel)
            make.leading.equalTo(questionTextView).offset(8)
        }
                   
        questionTextView.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(20)
            make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.height.lessThanOrEqualToSuperview().multipliedBy(0.45)
            make.height.greaterThanOrEqualToSuperview().multipliedBy(0.25)
        }
        
        answerContainerView.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
            containerBottomConstraint = make.bottom.equalToSuperview().constraint
        }
    }
    
    private func animate() {
        questionTextView.slam()
        answerContainerView.slide(from: .bottom, offset: 200.0)
    }
    
    
    // MARK: Helper Methods - 

    func startTimer() {
       timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            self.timerCounter -= 1
           
            DispatchQueue.main.async {
                self.timerLabel.text = "\(self.timerCounter)"
            }
            
            if self.timerCounter == 0 {
                timer.invalidate()
                self.submitAnswer(text: self.answerContainerView.answerTextField.text)
            }
        }
        
        timerLabel.pulse(scale: 1.3, duration: 0.5)
    }
    
    func submitAnswer(text: String?) {
        guard !answered else { return }
        answered = true
        
        GameManager.shared.answerQuestion(text) { error in
            if let error = error {
                self.answered = false
                self.presentError(error: error)
            } else {
                self.goToVotingController()
            }            
        }
    }
    
    private func goToVotingController() {
        let vc = VotingController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
            
    @objc private func showKeyboard(sender: NSNotification) {
        
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            self.containerBottomConstraint?.update(offset: -keyboardHeight)
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func hideKeyboard(sender: NSNotification) {
        self.containerBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
}

extension QuestionController: AnswerContainerDelegate {

    func send(text: String?) {
        timer?.invalidate()
        submitAnswer(text: text)
    }
}

