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
    let classicFirstColor = UIColor(r: 48, g: 62, b: 48, a: 1)
    let classicSecondColor = UIColor(r: 69, g: 80, b: 69, a: 1)
    let letterFirstColor = UIColor(r: 48, g: 62, b: 48, a: 1)
    let letterSecondColor = UIColor(r: 69, g: 80, b: 69, a: 1)
    let redBlackFirstColor = UIColor(r: 132,g: 51,b: 58,a: 1)
    let redBlackSecondColor = UIColor.black
}
