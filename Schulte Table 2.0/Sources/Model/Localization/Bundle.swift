//
//  Bundle.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 09.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

final class LocalizedBundle: Bundle {
    // Enforces usage of .lproj
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = Bundle.main.localizedBundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    private struct AssociatedKeys {
        static var bundle = "LocalizedMainBundle"
    }
    
    fileprivate var localizedBundle: Bundle? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.bundle) as? Bundle
        }
    }
    
    // Loads the translations for the given language code.
    static func enforceLanguage(_ code: String) {
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj") else { return }
        guard let bundle = Bundle(path: path) else { return }
        
        objc_setAssociatedObject(Bundle.main, &AssociatedKeys.bundle, bundle, .OBJC_ASSOCIATION_RETAIN)
        
        DispatchQueue.once(token: AssociatedKeys.bundle) {
            object_setClass(Bundle.main, LocalizedBundle.self)
        }
    }
    
    // Clears custom bundle
    static func clearInAppOverrides() {
        objc_setAssociatedObject(Bundle.main, &AssociatedKeys.bundle, nil, .OBJC_ASSOCIATION_RETAIN)
    }
}
