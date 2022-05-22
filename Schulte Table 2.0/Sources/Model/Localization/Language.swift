//
//  Language.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 06.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

enum Language: String, CaseIterable {
    case en = "en"
    case ru = "ru"
    
    var string: String {
        switch self {
        case .en:
            return "English"
        case .ru:
            return "Русский"
        }
    }
}
