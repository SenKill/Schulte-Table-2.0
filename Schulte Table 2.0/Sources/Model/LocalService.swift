//
//  LocalService.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 24.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

enum DefaultKeys: String {
    case classicPrev = "classicPrevious"
    case classicBest = "classicBest"
    case lettersPrev = "lettersPrevious"
    case lettersBest = "lettersBest"
    case redBlackPrev = "redBlackPrevious"
    case redBlackBest = "redBlackBest"
}

class LocalService {
    let defaults = UserDefaults.standard
    
    private func setResult(yourResult result: Double, forKey key: DefaultKeys) {
        defaults.set(result ,forKey: key.rawValue)
    }
    
    private func getResult(forKey key: DefaultKeys) -> Double {
        return defaults.double(forKey: key.rawValue)
    }
    
    func removeResult() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "classicPrevious")
        defaults.removeObject(forKey: "classicBest")
        defaults.removeObject(forKey: "lettersPrevious")
        defaults.removeObject(forKey: "lettersBest")
        defaults.removeObject(forKey: "redblackPrevious")
        defaults.removeObject(forKey: "redblackBest")
    }
}

extension LocalService {
    // Checking the current result and saving it in the UserDefault if it's less than the previous best result
    func handleEndGame(bestKey: DefaultKeys, previousKey: DefaultKeys, timeInfo: (Int, Int)) -> (Double, Double, Double) {
        
        let bestResult: Double = getResult(forKey: bestKey)
        let previousResult: Double  = getResult(forKey: previousKey)
        let currentResult: Double = Double(timeInfo.0) + Double(timeInfo.1) / 100
        if currentResult < bestResult || bestResult == 0.0 {
            setResult(yourResult: currentResult, forKey: bestKey)
        }
        
        setResult(yourResult: currentResult, forKey: previousKey)
        return (previousResult, currentResult, bestResult)
    }
}
