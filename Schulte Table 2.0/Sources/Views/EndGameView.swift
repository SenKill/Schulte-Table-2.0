//
//  EndGameView.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 24.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

class EndGameView: UIView {
    
    private let currentValue: Double
    private let bestValue: Double
    private let previousValue: Double
    private var gameType: GameType
    private var tableSize: TableSize!
    
    
    init(frame: CGRect, previous: Double, current: Double, best: Double, game: GameType, table: TableSize) {
        previousValue = previous
        currentValue = current
        bestValue = best
        gameType = game
        tableSize = table
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        currentValue = 0.0
        bestValue = 0.0
        previousValue = 0.0
        gameType = .classic
        super.init(coder: coder)
    }
    
    private func setViews() {
        let gameTypeLocalized = String(describing: gameType).localized
        installLabel(withYpos: 75, withText: "\(gameTypeLocalized), \(tableSize.string) " + "grid".localized, withColor: .lightGray, withFontSize: 25)
        let bestText = "BEST_RESULT".localized + String(format: "%.2f", bestValue) + "sec".localized
        installLabel(withYpos: bounds.midY - 250, withText: bestText, withColor: UIColor(r: 255, g: 215, b: 0, a: 0.8), withFontSize: 30)
        let yourText: String = "YOUR_RESULT".localized + String(format: "%.2f", currentValue) + "sec".localized
        installLabel(withYpos: bounds.midY - 50, withText: yourText, withColor: UIColor(r: 156, g: 192, b: 231, a: 0.8), withFontSize: 40)
        let previousText = "PREVIOUS_RESULT".localized + String(format: "%.2f", previousValue) + "sec".localized
        installLabel(withYpos: bounds.midY + 150, withText: previousText, withColor: UIColor(r: 255, g: 160, b: 122, a: 0.8), withFontSize: 30)
        
    }
}

// MARK: Internal
private extension EndGameView {
    func installLabel(withYpos yPos: CGFloat, withText text: String, withColor color: UIColor, withFontSize fontSize: CGFloat) {
        let fontName: String = "Rockwell"
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        label.center = CGPoint(x: bounds.midX, y: yPos)
        label.textAlignment = .center
        label.font = UIFont(name: fontName, size: fontSize)
        label.text = text
        label.textColor = color
        label.numberOfLines = 0
        addSubview(label)
    }
}
