//
//  ViewController.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 7/16/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import UIKit
import CoreMedia
import AVFAudio

class HomeViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var nextTargetLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var labelsView: UIView!
    @IBOutlet var restartButton: UIBarButtonItem!
    @IBOutlet weak var buttonsCollectionView: UICollectionView!
    
    private let buttonsVC = ButtonsCollectionViewController()
    private let localService = LocalService()
    private let transition = SlideInTransition()
    private let stopwatch = Stopwatch()
    private var endGameView: EndGameView!
    private var numberOfItems = 25
    
    // Red-black properties
    private var targetColor: UIColor?
    private var nextTargetRed: Int?
    
    private var currentGameType: GameType = .classic
    private var gameResultPrevious: DefaultKeys = DefaultKeys.classicPrev
    private var gameResultBest: DefaultKeys = DefaultKeys.classicBest
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonsCollectionView.dataSource = buttonsVC
        buttonsCollectionView.delegate = buttonsVC
        buttonsVC.delegate = self
        stopwatch.delegate = self
        startGame(withType: .classic)
    }
}

// MARK: - Actions
extension HomeViewController {
    @IBAction func touchRestartButton(_ sender: UIBarButtonItem) {
        stopwatch.stop()
        startGame(withType: currentGameType)
    }
    
    // Set up other game types and include them into the side bar
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        guard let menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController else { return }
        
        menuViewController.delegate = self
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnDimmingView(_:)))
        transition.dimmingView.addGestureRecognizer(gesture)
    }
}

// MARK: - Internal
private extension HomeViewController {
    func startGame(withType gameType: GameType) {
        buttonsVC.currentGameType = gameType
        var titles: [String] = []
        var colors: [UIColor] = []
        let range = 1...numberOfItems
        switch gameType {
        case .classic:
            range.forEach { number in
                titles.append(String(number))
            }
            titles.shuffle()
            colors = getOrderedColors(first: UIColor.theme.classicFirstColor, second: UIColor.theme.classicSecondColor)
            
            buttonsVC.nextTarget = 1
            nextTargetLabel.text = String(buttonsVC.nextTarget)
            nextTargetLabel.textColor = .white
            
        case .letter:
            let rangeOfLetterNumbers = 97...121
            let letterNumbers = rangeOfLetterNumbers.shuffled()
            for i in range {
                let letter = String(Unicode.Scalar(letterNumbers[i-1])!)
                titles.append(letter)
            }
            
            colors = getOrderedColors(first: UIColor.theme.letterFirstColor, second: UIColor.theme.letterSecondColor)
            buttonsVC.nextTarget = 97
            nextTargetLabel.text = String(Unicode.Scalar(buttonsVC.nextTarget)!)
            nextTargetLabel.textColor = .white
            
        case .redBlack:
            colors = getDisorderedColors(first: UIColor.theme.redBlackFirstColor, second: UIColor.theme.redBlackSecondColor)
            buttonsVC.nextTarget = 1
            nextTargetRed = numberOfItems
            nextTargetLabel.text = String(buttonsVC.nextTarget)
            targetColor = UIColor.theme.redBlackSecondColor
            nextTargetLabel.textColor = .white
        }
        buttonsVC.titles = titles
        buttonsVC.colors = colors
        buttonsVC.numberOfItems = numberOfItems
        
        buttonsCollectionView.reloadSections(IndexSet(integer: 0))
        stopwatch.start()
    }
    
    func transitionToNew(_ gameType: GameType) {
        stopwatch.stop()
        let title = String(describing: gameType).capitalized
        self.title = title
        switch gameType {
        case .classic:
            self.currentGameType = .classic
            startGame(withType: .classic)
            gameResultPrevious = DefaultKeys.classicPrev
            gameResultBest = DefaultKeys.classicBest
            
        case .letter:
            self.currentGameType = .letter
            startGame(withType: .letter)
            gameResultPrevious = DefaultKeys.lettersPrev
            gameResultBest = DefaultKeys.lettersBest
            
        case .redBlack:
            self.currentGameType = .redBlack
            startGame(withType: .redBlack)
            gameResultPrevious = DefaultKeys.lettersPrev
            gameResultBest = DefaultKeys.lettersBest
        }
    }
    
    func getOrderedColors(first firstColor: UIColor, second secondColor: UIColor) -> [UIColor] {
        var colors: [UIColor] = []
    
        for i in 1...numberOfItems {
            if i%2 == 0 {
                colors.append(firstColor)
            } else {
                colors.append(secondColor)
            }
        }
        return colors
    }
    
    func getDisorderedColors(first firstColor: UIColor, second secondColor: UIColor) -> [UIColor] {
        var colors: [UIColor] = []
        let isNumberEven: Bool = numberOfItems % 2 == 0
        let firstRange = 1...(numberOfItems / 2)
        let secondRange = 1...(isNumberEven ? numberOfItems / 2 : numberOfItems / 2 + 1)
        
        for _ in firstRange {
            colors.append(firstColor)
        }
        for _ in secondRange {
            colors.append(secondColor)
        }
        return colors.shuffled()
    }
}

// MARK: - Obj-C functions
private extension HomeViewController {
    @objc func didTapOnDimmingView(_ sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapEndGameView(_ sender: UITapGestureRecognizer) {
        endGameView.removeFromSuperview()
        if let navigationController = navigationController {
            view.addSubview(navigationController.navigationBar)
        }
        labelsView.isHidden = false
        startGame(withType: currentGameType)
    }
}

// MARK: TransitionDelegate
extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
}

// MARK: StopwatchDelegate
extension HomeViewController: StopwatchDelegate {
    func stopwatch(secondsDidChanged seconds: Int) {
        timeLabel.text = "\(seconds)"
    }
}

// MARK: - MenuDelegate
extension HomeViewController: MenuDelegate {
    func menuDidResetResults() {
        stopwatch.stop()
        startGame(withType: currentGameType)
    }
    
    func menu(didSelectGameType gameType: GameType) {
        transitionToNew(gameType)
    }
}

// MARK: - ButtonsCollectionDelegate
extension HomeViewController: ButtonsCollectionDelegate {
    func buttonsCollection(changeTargetLabelWithText text: String, color: UIColor?) {
        nextTargetLabel.textColor = color ?? .white
        nextTargetLabel.text = text
    }
    
    func buttonsCollectionDidEndGame() {
        let statTuple = localService.handleEndGame(bestKey: gameResultBest, previousKey: gameResultPrevious, timeInfo: stopwatch.getTimeInfo())
        
        stopwatch.stop()
        labelsView.isHidden = true
        endGameView = EndGameView(frame: view.bounds.self, previous: statTuple.0, current: statTuple.1, best: statTuple.2)
        navigationController?.navigationBar.removeFromSuperview()
        
        view.addSubview(endGameView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEndGameView(_:)))
        endGameView.addGestureRecognizer(tapGestureRecognizer)
    }
}
