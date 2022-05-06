//
//  Language.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 06.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

enum Language: Int {
    case english = 0
    case russian = 1
    
    static let allCases: [Language] = [.english, .russian]
    
    var string: String {
        switch self {
        case .english:
            return "English"
        case .russian:
            return "Russian"
        }
    }
    
    // MARK: Hardcoded fix later!
    var localizedString: String {
        switch self {
        case .english:
            return "Английский"
        case .russian:
            return "Русский"
        }
    }
}
