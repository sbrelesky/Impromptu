//
//  ViewController.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import UIKit
import ViewAnimator

class LandingController: UIViewController {

    let imageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "icon"))
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.secondary(weight: .bold).font.withSize(50.0)
        l.textColor = Theme.Colors.text
        l.text = "Impromptu"
        l.textAlignment = .center
        
        return l
    }()
    
    lazy var joinButton: TPGButton = {
        let b = TPGButton(title: "Join Game", color: Theme.Colors.tertiary)
        b.addTarget(self, action: #selector(joinGamePressed), for: .touchUpInside)
        return b
    }()
    
    lazy var startButton: TPGButton = {
        let b = TPGButton(title: "Start Game", color: Theme.Colors.secondary)
        b.addTarget(self, action: #selector(startGamePressed), for: .touchUpInside)
        return b
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = Theme.Colors.primary
        navigationController?.navigationItem.hidesBackButton = true
        
        setupUI()
        animate()
        // joinGame(code: "72756", name: "Test")
    }

    // MARK: - Layout Methods
    
    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(startButton)
        view.addSubview(joinButton)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(-4)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Constants.Padding.Vertical.bottomSpacing)
            make.centerX.equalToSuperview()
        }
        
        joinButton.snp.makeConstraints { make in
            make.bottom.equalTo(startButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        }
    }
    
    private func animate() {
        // Set initial state for spring effect
        startButton.transform = CGAffineTransform(translationX: 0, y: 300)
        joinButton.transform = CGAffineTransform(translationX: 0, y: 300)

        animateButton(joinButton) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.animateButton(strongSelf.startButton, completion: nil)
        }
    }
    
    private func animateButton(_ button: UIButton, completion: ((Bool) -> Void)?) {
        let animations = [AnimationType.from(direction: .bottom, offset: 300)]

        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseInOut],
                       animations: {
            
            button.transform = .identity
            button.animate(animations: animations)
        }, completion: completion)
    }
    
    // MARK: - Button Targets

    @objc func joinGamePressed() {
        presentJoinGame(creating: false)
    }
    
    @objc func startGamePressed() {
        presentJoinGame(creating: true)
    }
    
    // MARK: - Helper Methods
    
    func presentJoinGame(creating: Bool) {
        let popup = JoinGamePopup(creating: creating)
        popup.delegate = self
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.present(popup, animated: true)
    }
    
    private func createGame(name: String) {
        GameManager.shared.createGame(name: name) { result in
            switch result {
            case .success(let code):
                self.goToHomeScreen(code: code)
            case .failure(let error):
                self.presentError(error: error)
            }
        }
    }
    
    private func joinGame(code: String, name: String) {
        GameManager.shared.joinGame(code: code, name: name) { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                self.goToHomeScreen(code: code)
            }
        }
    }
    
    private func goToHomeScreen(code: String) {
        GameManager.shared.fetchGame(code: code) { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                let vc = UINavigationController(rootViewController: HomeViewController())
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        }
    }
}

// MARK: - JoinGamePopupDelegate

extension LandingController: JoinGamePopupDelegate {
    
    func entered(gameCode: String?, name: String, creating: Bool) {
        if creating {
            createGame(name: name)
        } else {
            guard let code = gameCode else { return }
            joinGame(code: code, name: name)
        }
    }
}
