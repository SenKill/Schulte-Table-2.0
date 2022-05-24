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
    func buttonsCollectionReloadView()
}

class ButtonsCollectionViewController: UICollectionViewController {
    weak var delegate: ButtonsCollectionDelegate?
    var game: SchulteTable!
    var hardMode: Bool!
    var crazyMode: Bool!
    
    private let soundPlayer = SoundPlayer()
}

// MARK: - Data source
extension ButtonsCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        game.tableSize.items
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonsCollectionViewCell.reuseId, for: indexPath) as? ButtonsCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        var buttonTitle: String = ""
        if indexPath.row >= game.titles.startIndex && indexPath.row < game.titles.endIndex {
            buttonTitle = game.titles.isEmpty ? "" : game.titles[indexPath.row]
        }
        
        let buttonColor = game.colors[indexPath.row]
        if game.gameType == .redBlack {
            if buttonColor == UIColor.theme.redBlack[1] {
                buttonTitle = String(game.blackTitles[game.blackCount])
                game.blackCount += 1
            } else if buttonColor == UIColor.theme.redBlack[0] {
                buttonTitle = String(game.redTitles[game.redCount])
                game.redCount += 1
            }
        }
        
        for tableButton in game.passedButtons {
            if (tableButton.title == buttonTitle) && (tableButton.isRedButton == (buttonColor == UIColor.theme.redBlack[0])) {
                cell.button.isHidden = true
                return cell
            }
        }
        
        cell.configureCell(with: buttonTitle, color: buttonColor, crazyMode: crazyMode)
        cell.handleButtonAction = { button in
            if self.game.gameType == .redBlack {
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
            if game.gameType == .letter {
                textForTargetLabel = String(Unicode.Scalar(game.nextTarget)!)
            } else {
                textForTargetLabel = String(game.nextTarget)
            }
            delegate?.buttonsCollection(changeTargetLabelWithText: textForTargetLabel, color: nil)
            handleCorrectButton(button)
            return
        }
        soundPlayer.playSound(soundPath: soundPlayer.wrongSoundPath)
    }
    
    func checkRedBlackButton(_ button: UIButton) {
        // Decomposing if else logic, and storing it in the property below
        let isRightButton: Bool!
        let backgroundColorIsBlack: Bool = button.backgroundColor == UIColor.theme.redBlack[1]
        if game.targetColor == UIColor.theme.redBlack[1] {
            isRightButton = button.currentTitle == String(game.nextTarget) && backgroundColorIsBlack
        } else {
            isRightButton = button.currentTitle == String(game.nextTargetRed) && !backgroundColorIsBlack
        }
        
        // If the button was right then it will send the new text to the master through delegate
        if isRightButton {
            if game.targetColor == UIColor.theme.redBlack[1] {
                game.nextTarget += 1
                game.targetColor = UIColor.theme.redBlack[0]
                delegate?.buttonsCollection(changeTargetLabelWithText: String(game.nextTargetRed), color: game.targetColor)
            } else {
                game.nextTargetRed -= 1
                game.targetColor = UIColor.theme.redBlack[1]
                delegate?.buttonsCollection(changeTargetLabelWithText: String(game.nextTarget), color: .white)
            }
            handleCorrectButton(button)
            return
        }
        soundPlayer.playSound(soundPath: soundPlayer.wrongSoundPath)
    }
    
    func handleCorrectButton(_ button: UIButton) {
        soundPlayer.playSound(soundPath: soundPlayer.correctSoundPath)
        button.isHidden = true
        var tableButton = TableButton(title: button.title(for: .normal) ?? "")
        tableButton.isRedButton = button.backgroundColor == UIColor.theme.redBlack[0]
        
        // MARK: Hard Mode
        if hardMode {
            if game.gameType == .redBlack {
                game.redCount = 0
                game.blackCount = 0
                game.redTitles.shuffle()
                game.blackTitles.shuffle()
            } else {
                game.titles.shuffle()
            }
            game.passedButtons.append(tableButton)
            delegate?.buttonsCollectionReloadView()
        }
        
        // Checking if the button is the last
        if game.gameType == .redBlack {
            // MARK: For the red-black
            if (tableButton.isRedButton == (game.redBlackLastTarget == 1)) && (tableButton.title == String(game.redBlackLastTarget)) {
                delegate?.buttonsCollectionDidEndGame()
            }
        } else {
            // MARK: For the others
            if game.nextTarget == game.tableSize.items+1 || game.nextTarget == game.letterLastTarget {
                delegate?.buttonsCollectionDidEndGame()
            }
        }
    }
}
