//
//  ViewController.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 7/16/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import UIKit
import AVFoundation

extension Sequence {
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var nextNumberLabel: UILabel!
    @IBOutlet var buttonsCollection: [UIButton]!
    
    var game = SchulteTable(gameType: "Classic")
    
    var audioPlayer: AVAudioPlayer?
    
    var timer = Timer()
    var (seconds, fractions) = (0, 0)
    var nextNumber = 1
    
    @IBAction func touchButton(_ sender: UIButton) {
        if let buttonNumber = buttonsCollection.firstIndex(of: sender) {
           checkButton(at: buttonNumber)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGame()
    }
    
    func startGame() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.keepTimer), userInfo: nil, repeats: true)
        
        (seconds, fractions) = (0, 0)
        nextNumber = 1
        nextNumberLabel.text = String(nextNumber)
        let range = 1...25
        let buttonNum = range.shuffled()
        var button: UIButton
        
        for i in range {
            button = buttonsCollection[i-1]
            button.setTitle(String(buttonNum[i-1]), for: .normal)
        }
    }
    
    func endGame() {
        startGame()
    }
    
    func checkButton(at index: Int) {
        if let button = buttonsCollection[index].currentTitle {
            if button == String(nextNumber) {
                buttonsCollection[index].backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                buttonsCollection[index].setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.6247603528), for: .normal)
                let pathToSound = Bundle.main.path(forResource: "correct", ofType: "wav")
                let url = URL(fileURLWithPath: pathToSound!)
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                } catch {
                    
                }
                nextNumber += 1
                if nextNumber <= 25 {
                    nextNumberLabel.text = String(nextNumber)
                } else {
                    endGame()
                }
            }
            else {
                let pathToSound = Bundle.main.path(forResource: "wrong", ofType: "wav")
                let url = URL(fileURLWithPath: pathToSound!)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                } catch {
                    
                }
            }
        }
    }
    
    @objc func keepTimer() {
        fractions += 1
        if fractions > 99 {
            seconds += 1
            fractions = 0
        }
        
        timeLabel.text = "\(seconds)"
    }
}
