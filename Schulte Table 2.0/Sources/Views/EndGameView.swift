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
    
    var currentValue: Double
    var bestValue: Double
    var previousValue: Double
    let fontName: String = "Rockwell"
    
    init(frame: CGRect, previous: Double, current: Double, best: Double) {
        previousValue = previous
        currentValue = current
        bestValue = best
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        currentValue = 0.0
        bestValue = 0.0
        previousValue = 0.0
        super.init(coder: coder)
    }
    
    private func setViews() {
        installLabel(withYpos: 50, withText: "Your result:\n\(currentValue)s", withColor: UIColor(r: 156, g: 192, b: 231, a: 1), withFontSize: 40)
        installLabel(withYpos: 250, withText: "Best result:\n\(bestValue)s", withColor: UIColor(r: 255, g: 215, b: 0, a: 0.7), withFontSize: 30)
        installLabel(withYpos: -150, withText: "Previous result:\n\(previousValue)s", withColor: UIColor(r: 255, g: 160, b: 122, a: 0.8), withFontSize: 30)
        
    }
}

// MARK: Internal
private extension EndGameView {
    func installLabel(withYpos yPos: CGFloat, withText text: String, withColor color: UIColor, withFontSize fontSize: CGFloat) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        label.center = CGPoint(x: bounds.midX, y: bounds.midY - yPos)
        label.textAlignment = .center
        label.font = UIFont(name: fontName, size: fontSize)
        label.text = text
        label.textColor = color
        label.numberOfLines = 0
        addSubview(label)
    }
}
