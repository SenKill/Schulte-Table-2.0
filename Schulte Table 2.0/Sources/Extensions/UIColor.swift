//
//  UIColor.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 25.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    // Simplifies UIColor initialization
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    static let theme = Theme()
}

struct Theme {
    let defaultButtons: [UIColor] = [UIColor(r: 48, g: 62, b: 48, a: 1), UIColor(r: 69, g: 80, b: 69, a: 1)]
    let crazyModeTitles: [UIColor] = [.systemBlue,.systemBrown,.systemGreen,.systemIndigo,.systemOrange,.systemPink,.systemPurple,.systemRed,.systemTeal,.systemYellow,.systemGray]
    
    let redBlack: [UIColor] = [UIColor(r: 132,g: 51,b: 58,a: 1), UIColor.black]
    
    let menuCell = UIColor(r: 245, g: 228, b: 195, a: 1)
    let highlitedMenuCell = UIColor(r: 215, g: 200, b: 165, a: 1)
    
    let statsSmallCell = UIColor(named: "StatsSmallColor")!
    let statsMediumCell = UIColor(named: "StatsMediumColor")!
    let statsLargeCell = UIColor(named: "StatsLargeColor")!
    let statsHugeCell = UIColor(named: "StatsHugeColor")!
}
