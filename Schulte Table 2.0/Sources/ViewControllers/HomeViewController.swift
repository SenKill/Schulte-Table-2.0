//
//  ViewController.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 7/16/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var nextTargetLabel: UILabel!
    @IBOutlet var buttonsCollection: [UIButton]!
    @IBOutlet var labelsView: UIView!
    @IBOutlet var restartButton: UIBarButtonItem!
    
    let localService = LocalService()
    let transition = SlideInTransition()
    var endGameView: EndGameView!
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var (seconds, fractions) = (0, 0)
    var nextTarget = 1
    
    lazy var targetColor: UIColor = .black
    lazy var nextTargetRed = 12
    lazy var isBlack = true
    
    var lastGameType: GameType = .classic
    var gameResultPrevious: DefaultKeys = DefaultKeys.classicPrev
    var gameResultBest: DefaultKeys = DefaultKeys.classicBest
    
    @IBAction func touchButton(_ sender: UIButton) {
        if let buttonNumber = buttonsCollection.firstIndex(of: sender) {
           checkButton(at: buttonNumber)
        }
    }
    @IBAction func touchRestartButton(_ sender: UIBarButtonItem) {
        stopTimer()
        startGame(withType: lastGameType)
    }
    
    // Side bar menu
    // Set up other game types and include they into side bar
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        guard let menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController else { return }
        menuViewController.didTapMenuType = { GameType in
            self.transitionToNew(GameType)
        }
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnDimmingView(_:)))
        transition.dimmingView.addGestureRecognizer(gesture)
    }
    
    @objc func didTapOnDimmingView(_ sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func transitionToNew(_ GameType: GameType) {
        let title = String(describing: GameType).capitalized
        self.title = title
        
        switch GameType {
            case .classic:
                lastGameType = .classic
                startGame(withType: .classic)
                gameResultPrevious = DefaultKeys.classicPrev
                gameResultBest = DefaultKeys.classicBest
            
            case .letter:
                lastGameType = .letter
                startGame(withType: .letter)
                gameResultPrevious = DefaultKeys.lettersPrev
                gameResultBest = DefaultKeys.lettersBest
            
            case .redBlack:
                lastGameType = .redBlack
                startGame(withType: .redBlack)
                gameResultPrevious = DefaultKeys.lettersPrev
                gameResultBest = DefaultKeys.lettersBest
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGame(withType: .classic)
    }
    
    func startGame(withType gameType: GameType) {
        view.addSubview(navigationController!.navigationBar)
        
        seconds = 0
        fractions = 0
        
        let range = 1...25
        labelsView.isHidden = false
        var button: UIButton
        
        switch gameType {
            case .classic:
                buttonsColoring(firstButtonColor: UIColor(r: 48, g: 62, b: 48, a: 1), secondButtonColor: UIColor(r: 69, g: 80, b: 69, a: 1), withShuffle: false)
                
                let buttonNum = range.shuffled()
                
                for i in range {
                    button = buttonsCollection[i-1]
                    button.setTitle(String(buttonNum[i-1]), for: .normal)
                }
                nextTarget = 1
                nextTargetLabel.text = String(nextTarget)
                nextTargetLabel.textColor = .white

            
            case .letter:
                buttonsColoring(firstButtonColor: UIColor(r: 48, g: 62, b: 48, a: 1), secondButtonColor: UIColor(r: 69, g: 80, b: 69, a: 1), withShuffle: false)
                
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
                buttonsColoring(firstButtonColor: UIColor(r: 132,g: 51,b: 58,a: 1), secondButtonColor: .black, withShuffle: true)
            
                nextTarget = 1
                nextTargetRed = 12
                nextTargetLabel.text = String(nextTarget)
                isBlack = true
                targetColor = .black
                nextTargetLabel.textColor = .white
        }

        startTimer()
    }

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
        
        let bestResult: Double  = localService.getResult(forKey: gameResultBest)
        let previousResult: Double  = localService.getResult(forKey: gameResultPrevious)
        let currentResult: Double = convertTimeToDouble(yourSeconds: seconds, yourFractions: fractions)
        
        stopTimer()
        
        labelsView.isHidden = true
        
        endGameView = EndGameView(frame: view.bounds.self, current: currentResult, best: bestResult, previous: previousResult)
        navigationController?.navigationBar.removeFromSuperview()
        
        if currentResult < localService.getResult(forKey: gameResultBest) || localService.getResult(forKey: gameResultBest) == 0.0 {
            localService.setResult(yourResult: currentResult, forKey: gameResultBest)
        }
        
        localService.setResult(yourResult: currentResult, forKey: gameResultPrevious)
        
        view.addSubview(endGameView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEndGameView(_:)))
        endGameView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func convertTimeToDouble(yourSeconds mySeconds: Int, yourFractions myFractions: Int) -> Double {
        return Double(mySeconds) + Double(myFractions) / 100
    }
    
    @objc func didTapEndGameView(_ sender: UITapGestureRecognizer) {
        endGameView.removeFromSuperview()
        startGame(withType: lastGameType)
    }
    
    func startTimer() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(timeInterval: 0.01,
                                     target:    self,
                                     selector:  #selector(HomeViewController.keepTimer),
                                     userInfo:  nil,
                                     repeats:   true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func checkButton(at index: Int) {
        guard buttonsCollection[index].currentTitleColor != #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0) else { return }
        let correctSound = {
            let pathToSound = Bundle.main.path(forResource: "correct", ofType: "wav")
            let url = URL(fileURLWithPath: pathToSound!)
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.play()
            } catch {
                
            }
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            self.buttonsCollection[index].backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 0)
            self.buttonsCollection[index].setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0), for: .normal)
        }
        
        let wrongSound = {
            let pathToSound = Bundle.main.path(forResource: "wrong", ofType: "wav")
            let url = URL(fileURLWithPath: pathToSound!)
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.play()
            } catch {
                
            }
        }
        
        if lastGameType == .redBlack {
            if ((buttonsCollection[index].currentTitle == String(nextTarget) && targetColor == .black || buttonsCollection[index].currentTitle == String(nextTargetRed) && targetColor == UIColor(r: 132, g: 51, b: 58, a: 1)) && buttonsCollection[index].backgroundColor == targetColor) {
                    correctSound()
                    if isBlack {
                        targetColor = UIColor(r: 132,g: 51,b: 58,a: 1) // red
                        nextTargetLabel.textColor = targetColor
                        nextTargetLabel.text = String(nextTargetRed)
                        nextTarget += 1
                        isBlack = false
                    }
                    else {
                        targetColor = .black // black
                        nextTargetLabel.textColor = .white
                        nextTargetLabel.text = String(nextTarget)
                        nextTargetRed -= 1
                        isBlack = true
                    }
                }
                else {
                    wrongSound()
                }
        }
        else {
            if buttonsCollection[index].currentTitle == String(nextTarget) || buttonsCollection[index].currentTitle == String(Unicode.Scalar(nextTarget)!) {
                correctSound()
                nextTarget += 1
                if lastGameType == .letter {
                    nextTargetLabel.text = String(Unicode.Scalar(nextTarget)!)
                }
                else {
                    nextTargetLabel.text = String(nextTarget)
                }
            }
            else {
                wrongSound()
            }
        }
        if nextTarget == 26 && lastGameType != .letter || nextTarget == 14 && lastGameType != .classic || nextTarget == 122 { endGame() }
    }
    
    @objc func keepTimer() {
        fractions += 1
        seconds += fractions / 100
        fractions %= 100
        
        timeLabel.text = "\(seconds)"
    }
}

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
