//
//  TableSize.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 03.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

enum TableSize: Int {
    case small = 0
    case medium = 1
    case big = 2
    case huge = 3
    
    var name: String {
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
    
    var numberOfItems: Int {
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
}