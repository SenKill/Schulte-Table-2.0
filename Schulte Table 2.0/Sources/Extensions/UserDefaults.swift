//
//  UserDefaults.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 08.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Key {
        static let languageCode = "languageCode"
        static let regionCode = "regionCode"
        static let shuffleColors = "shuffleColors"
        static let hardMode = "hardMode"
        static let crazyMode = "crazyMode"
        static let hideInterface = "hideInterface"
        static let vibration = "vibration"
    }
    
    static var languageCode: String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: Key.languageCode)
        }
        set(value) {
            let defaults = UserDefaults.standard
            if let value = value {
                defaults.set(value, forKey: Key.languageCode)
                return
            }
            defaults.removeObject(forKey: Key.languageCode)
        }
    }
    
    static var regionCode: String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: Key.regionCode)
        }
        set(value) {
            let defaults = UserDefaults.standard
            if let value = value {
                defaults.set(value, forKey: Key.regionCode)
                return
            }
            defaults.removeObject(forKey: Key.regionCode)
        }
    }
}
