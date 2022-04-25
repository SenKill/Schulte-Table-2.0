//
//  ViewController.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 7/16/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import UIKit
import CoreMedia

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var nextTargetLabel: UILabel!
    @IBOutlet var buttonsCollection: [UIButton]!
    @IBOutlet var labelsView: UIView!
    @IBOutlet var restartButton: UIBarButtonItem!
    
    private let localService = LocalService()
    private let transition = SlideInTransition()
    private let stopwatch = Stopwatch()
    private let soundPlayer = SoundPlayer()
    private var endGameView: EndGameView!
    private var nextTarget = 1
    
    // Red-black properties
    private var targetColor: UIColor?
    private var nextTargetRed: Int?
    
    private var gameType: GameType = .classic
    private var gameResultPrevious: DefaultKeys = DefaultKeys.classicPrev
    private var gameResultBest: DefaultKeys = DefaultKeys.classicBest
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        stopwatch.delegate = self
        startGame(withType: .classic)
    }
}

// MARK: - Actions
extension HomeViewController {
    @IBAction func touchButton(_ sender: UIButton) {
        if let buttonNumber = buttonsCollection.firstIndex(of: sender) {
            checkButton(at: buttonNumber)
        }
    }
    
    @IBAction func touchRestartButton(_ sender: UIBarButtonItem) {
        stopwatch.stop()
        startGame(withType: gameType)
    }
    
    // Set up other game types and include them into the side bar
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        guard let menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController else { return }
        
        menuViewController.didTapMenuType = { gameType in
            self.transitionToNew(gameType)
        }
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
        var button: UIButton
        let range = 1...25
        
        switch gameType {
        case .classic:
            buttonsColoring(firstButtonColor: UIColor.theme.classicFirstColor, secondButtonColor: UIColor.theme.classicSecondColor, withShuffle: false)
            
            let buttonNum = range.shuffled()
            
            for i in range {
                button = buttonsCollection[i-1]
                button.setTitle(String(buttonNum[i-1]), for: .normal)
            }
            nextTarget = 1
            nextTargetLabel.text = String(nextTarget)
            nextTargetLabel.textColor = .white
            
            
        case .letter:
            buttonsColoring(firstButtonColor: UIColor.theme.letterFirstColor, secondButtonColor: UIColor.theme.letterSecondColor, withShuffle: false)
            
            let rangeOfLetterNumbers = 97...121
            let letterNumbers = rangeOfLetterNumbers.shuffled()
            for i in range {
                let letter = Unicode.Scalar(letterNumbers[i-1])!
                button = buttonsCollection[i-1]
                button.setTitle(String(letter), for: .normal)
            }
            nextTarget = 97
            nextTargetLabel.text = String(Unicode.Scalar(nextTarget)!)
            nextTargetLabel.textColor = .white
            
        case .redBlack:
            // Red-black game type
            buttonsColoring(firstButtonColor: UIColor.theme.redBlackFirstColor, secondButtonColor: UIColor.theme.redBlackSecondColor, withShuffle: true)
            
            nextTarget = 1
            nextTargetRed = 12
            nextTargetLabel.text = String(nextTarget)
            targetColor = UIColor.theme.redBlackSecondColor
            nextTargetLabel.textColor = .white
        }
        stopwatch.start()
    }
    
    func transitionToNew(_ GameType: GameType) {
        stopwatch.stop()
        let title = String(describing: GameType).capitalized
        self.title = title
        
        switch GameType {
        case .classic:
            gameType = .classic
            startGame(withType: .classic)
            gameResultPrevious = DefaultKeys.classicPrev
            gameResultBest = DefaultKeys.classicBest
            
        case .letter:
            gameType = .letter
            startGame(withType: .letter)
            gameResultPrevious = DefaultKeys.lettersPrev
            gameResultBest = DefaultKeys.lettersBest
            
        case .redBlack:
            gameType = .redBlack
            startGame(withType: .redBlack)
            gameResultPrevious = DefaultKeys.lettersPrev
            gameResultBest = DefaultKeys.lettersBest
        }
    }
    
    // TODO: Check this method if others are already has checked
    func buttonsColoring(firstButtonColor: UIColor, secondButtonColor: UIColor, withShuffle isShuffle: Bool) {
        var colors: [UIColor] = []
        var redNumber: [Int] = []
        var blackNumber: [Int] = []
        var numIndexBlack = 0
        var numIndexRed = 0
        
        if isShuffle {
            let redNumberRange = 1...12
            let blackNumberRange = 1...13
            redNumber = redNumberRange.shuffled()
            blackNumber = blackNumberRange.shuffled()
            
            for _ in 1...12 {
                colors.append(firstButtonColor)
            }
            for _ in 1...13 {
                colors.append(secondButtonColor)
            }
            colors = colors.shuffled()
        }
        
        for i in 0..<buttonsCollection.count {
            buttonsCollection[i].setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            if isShuffle {
                if colors[i] == .black {
                    buttonsCollection[i].backgroundColor = colors[i]
                    buttonsCollection[i].setTitle(String(blackNumber[numIndexBlack]), for: .normal)
                    numIndexBlack += 1
                }
                else {
                    buttonsCollection[i].backgroundColor = colors[i]
                    buttonsCollection[i].setTitle(String(redNumber[numIndexRed]), for: .normal)
                    numIndexRed += 1
                }
            }
            else {
                if i%2 == 0 {
                    buttonsCollection[i].backgroundColor = firstButtonColor
                }
                else {
                    buttonsCollection[i].backgroundColor = secondButtonColor
                }
            }
        }
    }
    
    func endGame() {
        let statTuple = localService.handleEndGame(bestKey: gameResultBest, previousKey: gameResultPrevious, timeInfo: stopwatch.getTimeInfo())
        
        stopwatch.stop()
        labelsView.isHidden = true
        endGameView = EndGameView(frame: view.bounds.self, previous: statTuple.0, current: statTuple.1, best: statTuple.2)
        navigationController?.navigationBar.removeFromSuperview()
        
        view.addSubview(endGameView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEndGameView(_:)))
        endGameView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // TODO: Refactor this method
    func checkButton(at index: Int) {
        guard buttonsCollection[index].currentTitleColor != .clear else { return }
        
        if gameType == .redBlack {
            guard let unwrappedNextTargetRed = nextTargetRed else { return }
            
            let isRightButton: Bool!
            if targetColor == UIColor.theme.redBlackSecondColor {
                isRightButton = buttonsCollection[index].currentTitle == String(nextTarget) && buttonsCollection[index].backgroundColor == UIColor.theme.redBlackSecondColor
            } else {
                isRightButton = buttonsCollection[index].currentTitle == String(unwrappedNextTargetRed) && buttonsCollection[index].backgroundColor == UIColor.theme.redBlackFirstColor
            }
                                 
            if isRightButton {
                handleCorrectButton(buttonsCollection[index])
                if targetColor == UIColor.theme.redBlackSecondColor {
                    nextTarget += 1
                    targetColor = UIColor.theme.redBlackFirstColor
                    nextTargetLabel.textColor = targetColor
                    nextTargetLabel.text = String(unwrappedNextTargetRed)
                } else {
                    nextTargetRed = unwrappedNextTargetRed - 1
                    targetColor = UIColor.theme.redBlackSecondColor
                    nextTargetLabel.textColor = .white
                    nextTargetLabel.text = String(nextTarget)
                }
            } else {
                soundPlayer.playWrong()
            }
        } else {
            if buttonsCollection[index].currentTitle == String(nextTarget) || buttonsCollection[index].currentTitle == String(Unicode.Scalar(nextTarget)!) {
                handleCorrectButton(buttonsCollection[index])
                nextTarget += 1
                if gameType == .letter {
                    nextTargetLabel.text = String(Unicode.Scalar(nextTarget)!)
                }
                else {
                    nextTargetLabel.text = String(nextTarget)
                }
            } else {
                soundPlayer.playWrong()
            }
        }
        if nextTarget == 26 && gameType != .letter || nextTarget == 14 && gameType != .classic || nextTarget == 122 {
            endGame()
        }
    }
    
    func handleCorrectButton(_ button: UIButton) {
        soundPlayer.playCorrect()
        button.backgroundColor = .clear
        button.setTitleColor(.clear, for: .normal)
    }
    
    @objc func didTapOnDimmingView(_ sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapEndGameView(_ sender: UITapGestureRecognizer) {
        endGameView.removeFromSuperview()
        if let navigationController = navigationController {
            view.addSubview(navigationController.navigationBar)
        }
        labelsView.isHidden = false
        
        startGame(withType: gameType)
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
