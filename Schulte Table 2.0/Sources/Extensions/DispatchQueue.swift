//
//  DispatchQueue.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 09.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

extension DispatchQueue {
    private static var onceTracker = [String]()
    
    // The method executing only once
    class func once(token: String, block: () -> Void) {
        objc_sync_enter(self);
        defer {
            objc_sync_exit(self)
        }
        
        if onceTracker.contains(token) { return }
        onceTracker.append(token)
        block()
    }
}
