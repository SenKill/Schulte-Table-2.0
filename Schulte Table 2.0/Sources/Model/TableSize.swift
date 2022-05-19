//
//  TableSize.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 03.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

enum TableSize: Int {
    case small = 1
    case medium = 2
    case big = 3
    case huge = 4
    
    static let allCases: [TableSize] = [.small, .medium, .big, .huge]
    
    var string: String {
        switch self {
        case .small:
            return "3x3"
        case .medium:
            return "5x5"
        case .big:
            return "7x7"
        case .huge:
            return "9x9"
        }
    }
    
    var items: Int {
        switch self {
        case .small:
            return 9
        case .medium:
            return 25
        case .big:
            return 49
        case .huge:
            return 81
        }
    }
    
    var statsColors: [UIColor] {
        switch self {
        case .small:
            return [UIColor.theme.statsSmallColor]
        case .medium:
            return [UIColor.theme.statsMediumColor]
        case .big:
            return [UIColor.theme.statsBigColor]
        case .huge:
            return [UIColor.theme.statsHugeColor]
        }
    }
}
