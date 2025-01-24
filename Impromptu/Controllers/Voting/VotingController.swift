//
//  VotingController.swift
//  TPG
//
//  Created by Shane on 5/22/24.
//

import Foundation
import UIKit
import SnapKit

class VotingController: GameBaseController, GameManagerDelegate{
    
    let questionTextView: UILabel = {
        let padding = 12.0
        //let tv = PaddedTextView(padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        let tv = UILabel(frame: .zero)
        tv.font = Theme.Fonts.Style.main(weight: .bold).font.withDynamicSize(30.0)
        tv.textColor = Theme.Colors.text
        tv.backgroundColor = .clear //Theme.Colors.darkBackground
        tv.layer.cornerRadius = 12.0
        tv.adjustsFontSizeToFitWidth = true
        tv.numberOfLines = 0
        
        return tv
    }()

    let questionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.secondary(weight: .demiBold).font.withSize(18.0)
        l.textColor = Theme.Colors.subheading
        l.text = "Question 1"
        l.textAlignment = .left
        
        return l
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false

        cv.dataSource = self
        cv.delegate = self
        cv.register(VotingCell.self, forCellWithReuseIdentifier: "cell")
        
        return cv
    }()
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl(frame: .zero)
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = Theme.Colors.darkBackground
        return pc
    }()
    
    lazy var voteButton: TPGButton = {
        let b = TPGButton(title: "Vote", color: Theme.Colors.tertiary)
        b.addTarget(self, action: #selector(vote), for: .touchUpInside)
        b.isHidden = true
        
        return b
    }()
    
    let waitingLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = Theme.Fonts.Style.main(weight: .regular).font
        l.text = "Waiting for other players to finish answering"
        l.textColor = Theme.Colors.text
        l.textAlignment = .center
        l.numberOfLines = 0
        
        return l
    }()
    
    var answers: [Answer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        pageControl.numberOfPages = answers.count
        pageControl.isHidden = false
        animate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        questionTextView.text = GameManager.shared.question?.text

        notifyGameDidUpdate()
        
        registerGameDidUpdateNotification()
                
        if GameManager.shared.currentPlayer?.isCreator == true {
            creatorObserveAnswers()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeGameDidUpdateNotification()
    }
    

    func notifyGameDidUpdate() {
        switch GameManager.shared.game?.status {
        case .questionCompleted:
            fetchAnswers()
        case .votingCompleted:
            goToRoundResults()
        default: break
        }
    }
    
    private func setupUI() {
        view.addSubview(questionLabel)
        view.addSubview(questionTextView)
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(voteButton)
        view.addSubview(waitingLabel)
        
        questionLabel.text = "Question \(GameManager.shared.currentRound + 1)"
        
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(questionTextView).offset(8)
        }
        
        questionTextView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(20)
            make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.height.lessThanOrEqualToSuperview().multipliedBy(0.45)
//            make.height.greaterThanOrEqualToSuperview().multipliedBy(0.25)
        }        
        
        voteButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).priority(.required)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(questionTextView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview() //.multipliedBy(0.9)
            make.bottom.equalTo(pageControl.snp.top).offset(-10)
        }
                
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(voteButton.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        waitingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(voteButton)
        }
    }
    
    private func animate() {
        questionTextView.slam()
        collectionView.animate()
        voteButton.animate()
    }
    
    /// ONLY the creator fo the game will call this method so the answers can be observed and
    /// the game status can be udpated appropriately.
    private func creatorObserveAnswers() {
        
        GameManager.shared.observeAnswers { result in
            switch result {
                case .success(let answers):
                    self.answers = answers
                case .failure(let error):
                    self.presentError(error: error)
            }
            
            // Check and set the questionsCompleted status
            self.checkQuestionsCompleted()
            
            // Check and set the votingCompleted status
            if self.checkAllVotesCompleted() && GameManager.shared.game?.status != .votingCompleted {
                self.setVotingCompleted()
            }
        }
    }
    
    
    private func fetchAnswers() {
        GameManager.shared.fetchAnswers { result in
            switch result {
            case .success(let answers):
                self.answers = answers.filter({ $0.playerId != GameManager.shared.currentPlayer?.id }).shuffled()
                self.pageControl.numberOfPages = self.answers.count
                self.waitingLabel.isHidden = true
                self.collectionView.reloadData()
                self.voteButton.isHidden = false
                
                if self.answers.count == 0 {
                    self.voteButton.setTitle("Next", for: .normal)
                }
                
            case .failure(let error):
                self.presentError(error: error)
            }
        }
    }
    
    /// This will check to see if the question has been
    /// answered by all players.
    private func checkQuestionsCompleted() {
        if self.answers.count == GameManager.shared.players.count {
            GameManager.shared.setGameStatus(.questionCompleted) { error in
                if let error = error {
                    self.presentError(error: error)
                }
            }
        }
    }
    
    /// This will check to make sure that all players have voted
    private func checkAllVotesCompleted() -> Bool {
        let votes = answers.compactMap({ $0.votes }).reduce(0, +)
        return votes == GameManager.shared.players.count
    }

    func setVotingCompleted() {
        GameManager.shared.detachAnswers()
        
        // Increment the player points
        GameManager.shared.setVotingCompleted { error in
            if let error = error {
                self.presentError(error: error)
            }
        }
    }
    
    @objc private func vote() {
        guard answers.count > 0 else {
            setVotingCompleted()
            return
        }
        
        let answer = answers[pageControl.currentPage]
        voted(answer: answer)
    }
    
    private func voted(answer: Answer) {                
        GameManager.shared.voteForAnswer(answer) { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                self.collectionView.isHidden = true
                self.voteButton.isHidden = true
                self.pageControl.isHidden = true
                self.waitingLabel.text = "Waiting for other players to finish voting"
                self.waitingLabel.isHidden = false
            }
        }
    }
    
    private func goToRoundResults() {
        let vc = RoundResultsController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension VotingController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VotingCell
        cell.answer = answers[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height * 0.875)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = pageIndex
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = pageIndex
    }
}


class CustomFlowLayout: UICollectionViewFlowLayout {
    
    let scaleFactor: CGFloat = 0.4

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes }) else { return nil }
        
        let centerX = collectionView!.contentOffset.x + collectionView!.bounds.width / 2

        for attribute in attributes {
            let distance = abs(attribute.center.x - centerX)
            let scale = max(1 - distance / collectionView!.bounds.width * scaleFactor, 0.6)
            attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        return attributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let layoutAttributes = layoutAttributesForElements(in: collectionView!.bounds)
        let centerX = proposedContentOffset.x + collectionView!.bounds.width / 2

        let closestAttribute = layoutAttributes?.sorted {
            abs($0.center.x - centerX) < abs($1.center.x - centerX)
        }.first ?? UICollectionViewLayoutAttributes()
        
        let targetOffset = CGPoint(x: closestAttribute.center.x - collectionView!.bounds.width / 2, y: proposedContentOffset.y)
        
        return targetOffset
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        let centerX = collectionView!.contentOffset.x + collectionView!.bounds.width / 2

        if let attribute = attributes {
            let distance = abs(attribute.center.x - centerX)
            let scale = max(1 - distance / collectionView!.bounds.width * scaleFactor, 0.6)
            attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
        }

        return attributes
    }
}

