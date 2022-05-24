//
//  TableSize.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 03.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

enum TableSize: Int, CaseIterable {
    case extraSmall = 1
    case small = 2
    case medium = 3
    case large = 4
    case extraLarge = 5
    case huge = 6
    case extraHuge = 7
    
    var string: String {
        switch self {
        case .extraSmall:
            return "3x3"
        case .small:
            return "4x4"
        case .medium:
            return "5x5"
        case .large:
            return "6x6"
        case .extraLarge:
            return "7x7"
        case .huge:
            return "8x8"
        case .extraHuge:
            return "9x9"
        }
    }
    
    var items: Int {
        switch self {
        case .extraSmall:
            return 9
        case .small:
            return 16
        case .medium:
            return 25
        case .large:
            return 36
        case .extraLarge:
            return 49
        case .huge:
            return 64
        case .extraHuge:
            return 81
        }
    }
    
    var statsColors: [UIColor] {
        switch self {
        case .extraSmall, .small:
            return [UIColor.theme.statsSmallCell]
        case .medium:
            return [UIColor.theme.statsMediumCell]
        case .large, .extraLarge:
            return [UIColor.theme.statsLargeCell]
        case .huge, .extraHuge:
            return [UIColor.theme.statsHugeCell]
        }
    }
}
