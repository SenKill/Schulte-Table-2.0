//
//  Stopwatch.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 25.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation

// Delegate for notifying a class that will use the stopwatch
protocol StopwatchDelegate: AnyObject {
    func stopwatch(secondsDidChanged seconds: Int)
}

class Stopwatch {
    weak var delegate: StopwatchDelegate?
    
    private var timer: Timer!
    private var seconds: Int = 0
    private var fractions: Int = 0
    
    func start() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target:    self,
            selector:  #selector(self.keepTimer),
            userInfo:  nil,
            repeats:   true
        )
    }
    
    func stop() {
        timer.invalidate()
        timer = nil
        seconds = 0
        fractions = 0
        delegate?.stopwatch(secondsDidChanged: seconds)
    }
    
    func getTimeInfo() -> (Int, Int) {
        (seconds, fractions)
    }
    
    // Timer calling this method every one milisecond
    @objc private func keepTimer() {
        fractions += 1
        seconds += fractions / 100
        
        if fractions == 100 {
            delegate?.stopwatch(secondsDidChanged: seconds)
        }
        
        fractions %= 100
    }
}
