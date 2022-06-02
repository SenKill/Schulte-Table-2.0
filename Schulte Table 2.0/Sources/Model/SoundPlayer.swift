//
//  SoundPlayer.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 25.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class SoundPlayer {
    enum ResourceNames {
        static let correct = "correct"
        static let wrong = "wrong"
        static let type = "wav"
    }
    
    private var audioPlayer: AVAudioPlayer?
    var correctSoundPath: URL?
    var wrongSoundPath: URL?
    
    let wrongVibGenerator = UIImpactFeedbackGenerator(style: .medium)
    let correctVibGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private var isVibrationOn: Bool {
        UserDefaults.standard.bool(forKey: UserDefaults.Key.vibration)
    }
    lazy var vibration = isVibrationOn
    
    init() {
        if let pathToCorrectSound = Bundle.main.path(forResource: ResourceNames.correct, ofType: ResourceNames.type) {
            correctSoundPath = URL(fileURLWithPath: pathToCorrectSound)
        }
        if let pathToWrongSound = Bundle.main.path(forResource: ResourceNames.wrong, ofType: ResourceNames.type) {
            wrongSoundPath = URL(fileURLWithPath: pathToWrongSound)
        }
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didChangedVibrationValue(_:)), name: .vibration, object: nil)
    }
    
    func playSound(soundPath: URL?) {
        guard let path = soundPath else {
            print("Error: Can't find sound path")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path, fileTypeHint: ResourceNames.type)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Unexpected error: \(error.localizedDescription)")
        }
        
        if vibration {
            if soundPath == correctSoundPath {
                correctVibGenerator.impactOccurred()
            } else {
                wrongVibGenerator.impactOccurred()
            }
        }
    }
}

private extension SoundPlayer {
    @objc func didChangedVibrationValue(_ notification: Notification) {
        if let vibration = notification.object as? Bool {
            self.vibration = vibration
        }
    }
}
