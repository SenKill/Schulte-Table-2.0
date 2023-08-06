//
//  GameInfo.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 02.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

protocol GameInfoDelegate: AnyObject {
    func gameInfo(changeTargetLabelWithText text: String, color: UIColor?)
    func gameInfoDidEndGame()
    func gameInfoReloadView()
}

final class GameInfo {
    // MARK: - Public properties
    weak var delegate: GameInfoDelegate?
    let gameType: GameType
    var tableSize: TableSize!
    var colors: [UIColor] = []
    var titles: [String] = []
    var pressedButtons: [TableButton] = []
    var firstTarget: String = ""
    
    lazy var redCount: Int = 0
    lazy var blackCount: Int = 0
    lazy var redTitles: [Int] = {
        (1...tableSize.items/2).shuffled()
    }()
    lazy var blackTitles: [Int] = {
        isItemsEven ? (1...tableSize.items/2).shuffled() : (1...tableSize.items/2 + 1).shuffled()
    }()
    
    // MARK: - Private properties
    private let soundPlayer = SoundPlayer()
    private var isItemsEven: Bool {
        tableSize.items % 2 == 0
    }
    private var letterLastTarget: Int?
    private var nextTarget = 1
    private var redBlackLastTarget: Int {
        isItemsEven ? 1 : tableSize.items/2 + 1
    }
    private lazy var targetColor: UIColor = UIColor.theme.redBlack[1]
    private lazy var nextTargetRed: Int = tableSize.items / 2
    
    // MARK: - Init
    init(gameType: GameType, tableSize: TableSize, shuffleColors: Bool, alertCallback: () -> Void) {
        self.gameType = gameType
        self.tableSize = tableSize
        self.pressedButtons = []
        let titlesAndColors = getButtonTitlesAndColors(shuffle: shuffleColors, alertCallback: alertCallback)
        self.titles = titlesAndColors.0
        self.colors = titlesAndColors.1
    }
}

// MARK: - Public functions
extension GameInfo {
    func checkButton(_ button: UIButton, isHardMode: Bool) {
        if button.currentTitle == String(nextTarget) || button.currentTitle == String(Unicode.Scalar(nextTarget)!) {
            nextTarget += 1
            if nextTarget == 123 {
                nextTarget = 65
            }
            var textForTargetLabel: String = ""
            if gameType == .letter {
                textForTargetLabel = String(Unicode.Scalar(nextTarget)!)
            } else {
                textForTargetLabel = String(nextTarget)
            }
            delegate?.gameInfo(changeTargetLabelWithText: textForTargetLabel, color: nil)
            handleCorrectButton(button, isHardMode: isHardMode)
        } else {
            soundPlayer.playSound(soundPath: soundPlayer.wrongSoundPath)
        }
    }
    
    func checkRedBlackButton(_ button: UIButton, isHardMode: Bool) {
        // Decomposing if else logic, and storing it in the property below
        let isRightButton: Bool!
        let backgroundColorIsBlack: Bool = button.backgroundColor == UIColor.theme.redBlack[1]
        if targetColor == UIColor.theme.redBlack[1] {
            isRightButton = button.currentTitle == String(nextTarget) && backgroundColorIsBlack
        } else {
            isRightButton = button.currentTitle == String(nextTargetRed) && !backgroundColorIsBlack
        }
        
        // If the button was right then it will send the new text to the master through delegate
        if isRightButton {
            if targetColor == UIColor.theme.redBlack[1] {
                nextTarget += 1
                targetColor = UIColor.theme.redBlack[0]
                delegate?.gameInfo(changeTargetLabelWithText: String(nextTargetRed), color: targetColor)
            } else {
                nextTargetRed -= 1
                targetColor = UIColor.theme.redBlack[1]
                delegate?.gameInfo(changeTargetLabelWithText: String(nextTarget), color: .white)
            }
            handleCorrectButton(button, isHardMode: isHardMode)
            return
        }
        soundPlayer.playSound(soundPath: soundPlayer.wrongSoundPath)
    }
}

// MARK: - Internal
private extension GameInfo {
    func handleCorrectButton(_ button: UIButton, isHardMode: Bool) {
        soundPlayer.playSound(soundPath: soundPlayer.correctSoundPath)
        button.isHidden = true
        var tableButton = TableButton(title: button.title(for: .normal) ?? "")
        tableButton.isRedButton = button.backgroundColor == UIColor.theme.redBlack[0]
        
        // MARK: Hard Mode
        if isHardMode {
            if gameType == .redBlack {
                redCount = 0
                blackCount = 0
                redTitles.shuffle()
                blackTitles.shuffle()
            } else {
                titles.shuffle()
            }
            pressedButtons.append(tableButton)
            delegate?.gameInfoReloadView()
        }
        
        // Checking if the button is the last
        if gameType == .redBlack {
            // MARK: For the red-black
            if (tableButton.isRedButton == (redBlackLastTarget == 1)) && (tableButton.title == String(redBlackLastTarget)) {
                delegate?.gameInfoDidEndGame()
            }
        } else {
            // MARK: For the others
            if nextTarget == tableSize.items+1 || nextTarget == letterLastTarget {
                delegate?.gameInfoDidEndGame()
            }
        }
    }
    
    func getButtonTitlesAndColors(shuffle: Bool, alertCallback: () -> Void) -> ([String], [UIColor]) {
        var titles: [String] = []
        var colors: [UIColor] = []
        let range: ClosedRange<Int> = 1...tableSize.items
        
        if gameType != .redBlack {
            colors = shuffle ?
            getDisorderedColors(first: UIColor.theme.defaultButtons[0], second: UIColor.theme.defaultButtons[1]) :
            getOrderedColors(first: UIColor.theme.defaultButtons[0], second: UIColor.theme.defaultButtons[1])
        }
        
        switch gameType {
        case .classic:
            titles = range.map({String($0)})
        case .letter:
            guard tableSize.rawValue < 6 else {
                alertCallback()
                return ([], [])
            }
            let smallCharacters = 97...122
            let capitalCharacters = 65...90
            let letterArray = Array(smallCharacters) + Array(capitalCharacters)
            for i in range {
                let letter = String(Unicode.Scalar(letterArray[i-1])!)
                titles.append(letter)
            }
            nextTarget = smallCharacters.first ?? 97
            letterLastTarget = self.nextTarget + range.count
        case .redBlack:
            colors = getDisorderedColors(first: UIColor.theme.redBlack[0], second: UIColor.theme.redBlack[1])
        }
        self.firstTarget = titles[0]
        titles.shuffle()
        return (titles, colors)
    }
    
    func getOrderedColors(first firstColor: UIColor, second secondColor: UIColor) -> [UIColor] {
        var colors: [UIColor] = []
        var isRowEven: Bool = false
        
        if isItemsEven {
            for i in 1...tableSize.items {
                if (!isRowEven && i%2 == 0) || (isRowEven && i%2 == 1) {
                    colors.append(firstColor)
                } else {
                    colors.append(secondColor)
                }
                if i % Int(sqrt(Double(tableSize.items))) == 0 {
                    isRowEven.toggle()
                }
            }
            return colors
        }
        
        for i in 1...tableSize.items {
            if i % 2 == 0 {
                colors.append(firstColor)
            } else {
                colors.append(secondColor)
            }
        }
        return colors
    }
    
    func getDisorderedColors(first firstColor: UIColor, second secondColor: UIColor) -> [UIColor] {
        var colors: [UIColor] = []
        let isNumberEven: Bool = tableSize.items % 2 == 0
        let firstRange = 1...(tableSize.items / 2)
        let secondRange = 1...(isNumberEven ? tableSize.items / 2 : tableSize.items / 2 + 1)
        
        for _ in firstRange {
            colors.append(firstColor)
        }
        for _ in secondRange {
            colors.append(secondColor)
        }
        return colors.shuffled()
    }
}

struct TableButton {
    let title: String
    var isRedButton: Bool = false
}
