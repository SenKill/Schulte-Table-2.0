//
//  SoundPlayer.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 25.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import AVFoundation

class SoundPlayer {
    enum ResourceNames {
        static let correct = "correct"
        static let wrong = "wrong"
        static let type = "wav"
    }
    
    private var audioPlayer: AVAudioPlayer?
    
    func playCorrect() {
        guard let pathToSound = Bundle.main.path(forResource: ResourceNames.correct, ofType: ResourceNames.type) else { return }
        let url = URL(fileURLWithPath: pathToSound)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func playWrong() {
        guard let pathToSound = Bundle.main.path(forResource: ResourceNames.wrong, ofType: ResourceNames.type) else { return }
        let url = URL(fileURLWithPath: pathToSound)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Unexpected error: \(error.localizedDescription)")
        }
    }
}
