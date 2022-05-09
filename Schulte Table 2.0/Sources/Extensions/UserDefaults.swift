//
//  UserDefaults.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 08.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

extension UserDefaults {
    private enum Key: String {
        case languageCode = "languageCode"
        case regionCode = "regionCode"
    }
    
    static var languageCode: String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: Key.languageCode.rawValue)
        }
        set(value) {
            let defaults = UserDefaults.standard
            if let value = value {
                defaults.set(value, forKey: Key.languageCode.rawValue)
                return
            }
            defaults.removeObject(forKey: Key.languageCode.rawValue)
        }
    }
    
    static var regionCode: String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: Key.regionCode.rawValue)
        }
        set(value) {
            let defaults = UserDefaults.standard
            if let value = value {
                defaults.set(value, forKey: Key.regionCode.rawValue)
                return
            }
            defaults.removeObject(forKey: Key.regionCode.rawValue)
        }
    }
}
