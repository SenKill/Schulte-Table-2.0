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
    var game: SchulteTable!
    var currentGameType: GameType = .classic
    
    private let soundPlayer = SoundPlayer()
}

// MARK: - Data source
extension ButtonsCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        game.tableSize.items
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonsCell.reuseId, for: indexPath) as? ButtonsCell else {
            return UICollectionViewCell()
        }
        
        var buttonTitle: String = game.titles.isEmpty ? "" : game.titles[indexPath.row]
        let buttonColor = game.colors[indexPath.row]
        if currentGameType == .redBlack {
            if buttonColor == UIColor.theme.redBlackSecondColor {
                buttonTitle = String(game.blackTitles[game.blackCount])
                game.blackCount += 1
            } else if buttonColor == UIColor.theme.redBlackFirstColor {
                buttonTitle = String(game.redTitles[game.redCount])
                game.redCount += 1
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
        let bounds = UIScreen.main.bounds
        let cellWidth = (bounds.width / sqrt(CGFloat(game.tableSize.items))) - 1
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

// MARK: - Internal
private extension ButtonsCollectionViewController {
    func checkButton(_ button: UIButton) {
        if button.currentTitle == String(game.nextTarget) || button.currentTitle == String(Unicode.Scalar(game.nextTarget)!) {
            game.nextTarget += 1
            // Transition to capital letters in the Letter game type
            if game.nextTarget == 123 {
                game.nextTarget = 65
            }
            var textForTargetLabel: String = ""
            if currentGameType == .letter {
                textForTargetLabel = String(Unicode.Scalar(game.nextTarget)!)
            } else {
                textForTargetLabel = String(game.nextTarget)
            }
            delegate?.buttonsCollection(changeTargetLabelWithText: textForTargetLabel, color: nil)
            handleCorrectButton(button)
            return
        }
        soundPlayer.playWrong()
    }
    
    func checkRedBlackButton(_ button: UIButton) {
        // Decomposing if else logic, and storing it in the property below
        let isRightButton: Bool!
        let backgroundColorIsBlack: Bool = button.backgroundColor == UIColor.theme.redBlackSecondColor
        if game.targetColor == UIColor.theme.redBlackSecondColor {
            isRightButton = button.currentTitle == String(game.nextTarget) && backgroundColorIsBlack
        } else {
            isRightButton = button.currentTitle == String(game.nextTargetRed) && !backgroundColorIsBlack
        }
        
        // If the button was right then it will send the new text to the master through delegate
        if isRightButton {
            handleCorrectButton(button)
            if game.targetColor == UIColor.theme.redBlackSecondColor {
                game.nextTarget += 1
                game.targetColor = UIColor.theme.redBlackFirstColor
                delegate?.buttonsCollection(changeTargetLabelWithText: String(game.nextTargetRed), color: game.targetColor)
            } else {
                game.nextTargetRed -= 1
                game.targetColor = UIColor.theme.redBlackSecondColor
                delegate?.buttonsCollection(changeTargetLabelWithText: String(game.nextTarget), color: .white)
            }
            handleCorrectButton(button)
            return
        }
        soundPlayer.playWrong()
    }
    
    func handleCorrectButton(_ button: UIButton) {
        soundPlayer.playCorrect()
        button.isHidden = true
        
        // Checking if the button is the last
        if game.nextTarget == game.tableSize.items+1 || game.nextTarget == game.redBlackLastTarget && currentGameType != .classic || game.nextTarget == game.letterLastTarget {
            delegate?.buttonsCollectionDidEndGame()
        }
    }
}
