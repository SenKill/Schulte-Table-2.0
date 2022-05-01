//
//  ButtonsCollectionViewController.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 29.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

protocol ButtonsCollectionDelegate: AnyObject {
    func buttonsCollection(changeTargetLabelWithText text: String, color: UIColor?)
    func buttonsCollectionDidEndGame()
}

class ButtonsCollectionViewController: UICollectionViewController {
    weak var delegate: ButtonsCollectionDelegate?
    
    var numberOfItems: Int = 0
    var colors: [UIColor] = []
    var titles: [String] = []
    var currentGameType: GameType = .classic
    
    private let soundPlayer = SoundPlayer()
    
    var nextTarget = 1
    // Red-black properties
    private lazy var targetColor: UIColor = UIColor.theme.redBlackSecondColor
    private lazy var nextTargetRed: Int = numberOfItems / 2
    private lazy var redTitles: [Int] = (1...numberOfItems/2).shuffled()
    private lazy var blackTitles: [Int] = numberOfItems%2==0 ? (1...numberOfItems/2).shuffled() : (1...numberOfItems/2 + 1).shuffled()
    private lazy var redCount: Int = 0
    private lazy var blackCount: Int = 0
    
    // MARK: - View's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // TODO: Create and implement properly a reset method
    func resetGame() {
        nextTarget = 1
        targetColor = UIColor.theme.redBlackSecondColor
        nextTargetRed = numberOfItems / 2
        redTitles = (1...numberOfItems/2).shuffled()
        blackTitles = numberOfItems%2==0 ? (1...numberOfItems/2).shuffled() : (1...numberOfItems/2 + 1).shuffled()
        redCount = 0
        blackCount = 0
    }
}

// MARK: - Data source
extension ButtonsCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItems
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonsCell.reuseId, for: indexPath) as? ButtonsCell else {
            return UICollectionViewCell()
        }
        
        var buttonTitle: String = titles.isEmpty ? "" : titles[indexPath.row]
        let buttonColor = colors[indexPath.row]
        if currentGameType == .redBlack {
            if buttonColor == UIColor.theme.redBlackSecondColor {
                buttonTitle = String(blackTitles[blackCount])
                blackCount += 1
            } else if buttonColor == UIColor.theme.redBlackFirstColor {
                buttonTitle = String(redTitles[redCount])
                redCount += 1
            }
        }
        cell.configureCell(with: buttonTitle, color: buttonColor)
        cell.handleButtonAction = { button in
            if self.currentGameType == .redBlack {
                self.checkRedBlackButton(button)
            } else {
                self.checkButton(button)
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ButtonsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // TODO: Scale cells depending on the screen size
        CGSize(width: 82, height: 82)
    }
}

// MARK: - Internal
extension ButtonsCollectionViewController {
    func checkButton(_ button: UIButton) {
        if button.currentTitle == String(nextTarget) || button.currentTitle == String(Unicode.Scalar(nextTarget)!) {
            handleCorrectButton(button)
            nextTarget += 1
            var textForTargetLabel: String = ""
            if currentGameType == .letter {
                textForTargetLabel = String(Unicode.Scalar(nextTarget)!)
            } else {
                textForTargetLabel = String(nextTarget)
            }
            delegate?.buttonsCollection(changeTargetLabelWithText: textForTargetLabel, color: nil)
            checkIsLast(button)
            return
        }
        soundPlayer.playWrong()
    }
    
    func checkRedBlackButton(_ button: UIButton) {
        // Decomposing if else logic, and storing it in the property below
        let isRightButton: Bool!
        let backgroundColorIsBlack: Bool = button.backgroundColor == UIColor.theme.redBlackSecondColor
        if targetColor == UIColor.theme.redBlackSecondColor {
            isRightButton = button.currentTitle == String(nextTarget) && backgroundColorIsBlack
        } else {
            isRightButton = button.currentTitle == String(nextTargetRed) && !backgroundColorIsBlack
        }
        
        // If the button was right then it will send the new text to the master through delegate
        if isRightButton {
            handleCorrectButton(button)
            if targetColor == UIColor.theme.redBlackSecondColor {
                nextTarget += 1
                targetColor = UIColor.theme.redBlackFirstColor
                delegate?.buttonsCollection(changeTargetLabelWithText: String(nextTargetRed), color: targetColor)
            } else {
                nextTargetRed -= 1
                targetColor = UIColor.theme.redBlackSecondColor
                delegate?.buttonsCollection(changeTargetLabelWithText: String(nextTarget), color: .white)
            }
            checkIsLast(button)
            return
        }
        soundPlayer.playWrong()
    }
    
    func handleCorrectButton(_ button: UIButton) {
        soundPlayer.playCorrect()
        button.isHidden = true
    }
    
    func checkIsLast(_ button: UIButton) {
        // TODO: Make next target for letter game type adaptive
        if nextTarget == numberOfItems+1 && currentGameType != .letter || nextTarget == blackTitles.last && currentGameType != .classic || nextTarget == 122 {
            handleCorrectButton(button)
            delegate?.buttonsCollectionDidEndGame()
        }
    }
}
