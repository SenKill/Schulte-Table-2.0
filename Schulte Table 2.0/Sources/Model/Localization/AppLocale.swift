//
//  AppLocale.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 09.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

final class AppLocale {
    fileprivate var original: Locale
    fileprivate var originalPreferredLanguage: [String]
    private init() {
        original = Locale.current
        originalPreferredLanguage = Locale.preferredLanguages
    }
    
    static let shared = AppLocale()
    private var localeIdentifier: String {
        var components = NSLocale.components(fromLocaleIdentifier: original.identifier)
        
        // Loading saved language from UserDefaults and setting in to the components
        if let languageCode = UserDefaults.languageCode {
            components[NSLocale.Key.languageCode.rawValue] = languageCode
        }
        
        if let regionCode = UserDefaults.regionCode ?? original.regionCode {
            components[NSLocale.Key.countryCode.rawValue] = regionCode
        }
        
        // Checking if the app has this language
        
        let identifier = NSLocale.localeIdentifier(fromComponents: components)
        return identifier
    }
    static var identifier: String { return shared.localeIdentifier }
}

extension NSLocale {
    @objc class var app: Locale {
        return Locale(identifier: AppLocale.identifier)
    }
    
    @objc class var appPreferredLanguages: [String] {
        var arr = AppLocale.shared.originalPreferredLanguage
        if let languageCode = UserDefaults.languageCode, !arr.contains(languageCode) {
            arr.insert(languageCode, at: 0)
        }
        return arr
    }
}

extension Locale {
    fileprivate static var fallbackLanguageCode: String {
        AppLocale.shared.original.languageCode ?? "en"
    }
    
    fileprivate static var fallbackRegionCode: String? {
        AppLocale.shared.original.regionCode
    }
    
    fileprivate static func enforceLanguage(code: String, regionCode: String? = nil) {
        // Saves language to UserDefaults
        UserDefaults.languageCode = code
        UserDefaults.regionCode = regionCode
        
        // Loads translated bundle
        Bundle.enforceLanguage(code)
    }
    
    static func updateLanguage(code: String, regionCode: String? = nil) {
        enforceLanguage(code: code, regionCode: regionCode)
        
        // Posts notification so UI will update
        NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: Locale.current)
    }
    
    static func clearInAppOverrides() {
        UserDefaults.languageCode = nil
        UserDefaults.regionCode = nil
        
        Bundle.clearInAppOverrides()
        
        // Updates UI
        NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: Locale.current)
    }
    
    static func setupInitialLanguage() {
        let _ = AppLocale.shared
        
        if let languageCode = UserDefaults.languageCode {
            let regionCode = UserDefaults.regionCode
            enforceLanguage(code: languageCode, regionCode: regionCode)
            
            NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: Locale.current)
            return
        }
    }
}

