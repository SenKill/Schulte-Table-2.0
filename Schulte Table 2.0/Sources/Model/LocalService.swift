//
//  LocalService.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 24.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

enum DefaultKeys: String, CaseIterable {
    case classicPrev = "classicPrevious"
    case classicBest = "classicBest"
    case lettersPrev = "lettersPrevious"
    case lettersBest = "lettersBest"
    case redBlackPrev = "redBlackPrevious"
    case redBlackBest = "redBlackBest"
}

final class LocalService {
    private let defaults = UserDefaults.standard
    private let tableSizeKey = "tableSize"
    
    func removeResult() {
        let defaults = UserDefaults.standard
        
        for key in DefaultKeys.allCases {
            defaults.removeObject(forKey: key.rawValue + "3x3")
        }
        for key in DefaultKeys.allCases {
            defaults.removeObject(forKey: key.rawValue + "5x5")
        }
        for key in DefaultKeys.allCases {
            defaults.removeObject(forKey: key.rawValue + "7x7")
        }
        for key in DefaultKeys.allCases {
            defaults.removeObject(forKey: key.rawValue + "9x9")
        }
    }
}

extension LocalService {
    // Checking the current result and saving it in the UserDefault if it's less than the previous best result
    func handleEndGame(bestKey: DefaultKeys, previousKey: DefaultKeys, table size: TableSize, timeInfo: (Int, Int)) -> (Double, Double, Double) {
        
        let bestResult: Double = defaults.double(forKey: bestKey.rawValue + size.string)
        let previousResult: Double  = defaults.double(forKey: previousKey.rawValue + size.string)
        
        let currentResult: Double = Double(timeInfo.0) + Double(timeInfo.1) / 100
        if currentResult < bestResult || bestResult == 0.0 {
            defaults.set(currentResult, forKey: bestKey.rawValue + size.string)
        }
        
        defaults.set(currentResult, forKey: previousKey.rawValue + size.string)
        return (previousResult, currentResult, bestResult)
    }
}

// MARK: - TableSize
extension LocalService {
    var defaultTableSize: Int? {
        get {
            let value = defaults.integer(forKey: tableSizeKey)
            return value != 0 ? value : nil
        }
        set(value) {
            if let value = value {
                defaults.set(value, forKey: tableSizeKey)
            }
        }
    }
}
