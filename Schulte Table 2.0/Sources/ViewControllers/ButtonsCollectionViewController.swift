//
//  ButtonsCollectionViewController.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 29.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

final class ButtonsCollectionViewController: UICollectionViewController {
    var game: GameInfo!
    var hardMode: Bool!
    var crazyMode: Bool!
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.tableSize.items
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
        
        for tableButton in game.pressedButtons {
            if (tableButton.title == buttonTitle) && (tableButton.isRedButton == (buttonColor == UIColor.theme.redBlack[0])) {
                cell.button.isHidden = true
                return cell
            }
        }
        
        cell.configureCell(with: buttonTitle, color: buttonColor, crazyMode: crazyMode)
        cell.handleButtonAction = { button in
            if self.game.gameType == .redBlack {
                self.game.checkRedBlackButton(button, isHardMode: self.hardMode)
            } else {
                self.game.checkButton(button, isHardMode: self.hardMode)
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
