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
    
    func setResult(yourResult result: Double, forKey key: DefaultKeys) {
        defaults.set(result ,forKey: key.rawValue)
    }
    
    func getResult(forKey key: DefaultKeys) -> Double {
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
