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
    
    private let gameInfoLabel: UILabel = {
        getLabel(withColor: .lightGray, withFontSize: 25)
    }()
    
    private let bestLabel: UILabel = {
        getLabel(withColor: UIColor(r: 255, g: 215, b: 0, a: 0.8), withFontSize: 30)
    }()
    
    private let currentLabel: UILabel = {
        getLabel(withColor: UIColor(r: 156, g: 192, b: 231, a: 0.8), withFontSize: 40)
        
    }()
    
    private let previousLabel: UILabel = {
        getLabel(withColor: UIColor(r: 255, g: 160, b: 122, a: 0.8), withFontSize: 30)
    }()
    
    init(frame: CGRect, previous: Double, current: Double, best: Double, game: GameType, table: TableSize) {
        previousValue = previous
        currentValue = current
        bestValue = best
        gameType = game
        tableSize = table
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        setViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        currentValue = 0.0
        bestValue = 0.0
        previousValue = 0.0
        gameType = .classic
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previousLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bestLabel.frame.minY).isActive = true
    }
}

// MARK: Internal
private extension EndGameView {
    static func getLabel(withColor color: UIColor, withFontSize fontSize: CGFloat) -> UILabel {
        let fontName: String = "Gill Sans"
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: fontName, size: fontSize)
        label.textColor = color
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func setViews() {
        let gameInfoText = "\(String(describing: gameType).localized), \(tableSize.string) \("GRID".localized)"
        gameInfoLabel.text = gameInfoText
        let bestText = "BEST_RESULT".localized + bestValue.formatSeconds
        bestLabel.text = bestText
        let currentText: String = "YOUR_RESULT".localized + String(format: "%.2f", currentValue) + "SEC".localized
        currentLabel.text = currentText
        let previousText = "PREVIOUS_RESULT".localized + String(format: "%.2f", previousValue) + "SEC".localized
        previousLabel.text = previousText
        addSubview(gameInfoLabel)
        addSubview(bestLabel)
        addSubview(currentLabel)
        addSubview(previousLabel)
    }
    
    func layoutViews() {
        NSLayoutConstraint.activate([
            gameInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            gameInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            gameInfoLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            
            currentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            currentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            currentLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            bestLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            bestLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            bestLabel.topAnchor.constraint(equalTo: gameInfoLabel.bottomAnchor, constant: 30),
            
            previousLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            previousLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
