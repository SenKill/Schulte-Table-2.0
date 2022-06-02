//
//  SmallExtenions.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 24.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

// Extension that add the shuffle method on sequences
extension Sequence {
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension String {
    var localized: String {
        get {
            Bundle.main.localizedString(forKey: self, value: UserDefaults.languageCode, table: nil)
        }
    }
}

extension Double {
    var formatSeconds: String {
        String(format: "%.2f", self) + "SEC".localized
    }
}

extension Date {
    var format: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: AppLocale.identifier)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
}

extension Notification.Name {
    static let vibration = NSNotification.Name(rawValue: "VIBRATION_NOTIFICATION")
}

extension UIImage {
    static let background = Background()
}

struct Background {
    let owl = UIImage(named: "owl")
    let ape = UIImage(named: "ape")
    let clock = UIImage(named: "clock")
}
