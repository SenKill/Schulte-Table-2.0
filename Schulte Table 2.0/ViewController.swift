//
//  ViewController.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 7/16/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import UIKit
import AVFoundation

// Extension that simplify the init of UIColor
public extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
}

// Extension that add the shuffle method on sequences
extension Sequence {
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

struct DefaultKeys {
    static let keyOne = "previousResult"
    static let keyTwo = "bestResult"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var nextNumberLabel: UILabel!
    @IBOutlet var buttonsCollection: [UIButton]!
    var endGameView: UIView?
    var currentResult: Double?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var game = SchulteTable(gameType: "Classic")
    
    var audioPlayer: AVAudioPlayer?
    
    var timer: Timer?
    var (seconds, fractions) = (0, 0)
    var nextNumber = 1
    
    
    @IBAction func touchButton(_ sender: UIButton) {
        if let buttonNumber = buttonsCollection.firstIndex(of: sender) {
           checkButton(at: buttonNumber)
        }
    }
    
    @IBAction func touchRestartButton(_ sender: UIButton) {
        stopTimer()
        startGame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGame()
    }
    
    func startGame() {
        // TODO: Change color of buttons
        
        seconds = 0
        fractions = 0
        
        nextNumber = 1
        nextNumberLabel.text = String(nextNumber)
        for i in 0..<buttonsCollection.count {
            buttonsCollection[i].setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            if i%2 == 0 {
                buttonsCollection[i].backgroundColor = UIColor(r: 181, g: 178, b: 146, a: 1)
            }
            else {
                buttonsCollection[i].backgroundColor = UIColor(r: 168, g: 173, b: 180, a: 1)
            }
        }
        
        let range = 1...25
        let buttonNum = range.shuffled()
        var button: UIButton
        
        for i in range {
            button = buttonsCollection[i-1]
            button.setTitle(String(buttonNum[i-1]), for: .normal)
        }
        
        startTimer()
    }
    
    func endGame() {
        // TODO: Delete the time and the next number labels
        
        currentResult = convertTimeToDouble(yourSeconds: seconds, yourFractions: fractions)
        
        stopTimer()
        
        endGameView = UIView(frame: self.view.bounds.self)
        endGameView!.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5314057707)
        endGameView!.isUserInteractionEnabled = true
        
        if currentResult! < getResult(forKey: "bestResult") {
            setResult(yourResult: currentResult!, forKey: "bestResult")
        }
        
        let bestResult = String(getResult(forKey: "bestResult")) + "s"
        let previousResult = String(getResult(forKey: "previousResult")) + "s"
        
        installLabel(withYpos: 50, withText: "Your result:", withColor: UIColor(r: 156, g: 192, b: 231, a: 1), withFontSize: 40)
        installLabel(withYpos: 0, withText: "\(currentResult!)s", withColor: UIColor(r: 156, g: 192, b: 231, a: 1), withFontSize: 40)
        installLabel(withYpos: 250, withText: "Best result:", withColor: UIColor(r: 255, g: 215, b: 0, a: 0.7), withFontSize: 30)
        installLabel(withYpos: 200, withText: bestResult, withColor: UIColor(r: 255, g: 215, b: 0, a: 0.7), withFontSize: 30)
        installLabel(withYpos: -150, withText: "Previous result:", withColor: UIColor(r: 255, g: 160, b: 122, a: 0.8), withFontSize: 30)
        installLabel(withYpos: -200, withText: previousResult, withColor: UIColor(r: 255, g: 160, b: 122, a: 0.8), withFontSize: 30)
        
        
        setResult(yourResult: currentResult!, forKey: "previousResult")
        
        self.view.addSubview(endGameView!)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEndGameView(_:)))
        endGameView!.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    // Change the font size and the text color in this method
    func installLabel(withYpos yPos: CGFloat, withText text: String, withColor color: UIColor, withFontSize fontSize: CGFloat) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        label.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY - yPos)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.text = text
        label.textColor = color
    
        endGameView!.addSubview(label)
    }
    
    func convertTimeToDouble(yourSeconds mySeconds: Int, yourFractions myFractions: Int) -> Double {
        return Double(mySeconds) + Double(myFractions) / 100
    }
    
    func setResult(yourResult result: Double, forKey key: String) {
        let defaults = UserDefaults.standard
        defaults.set(result ,forKey: key)
    }
    
    func getResult(forKey key: String) -> Double {
        let defaults = UserDefaults.standard
        return defaults.double(forKey: key)
    }
    
    @objc func didTapEndGameView(_ sender: UITapGestureRecognizer) {
        endGameView?.removeFromSuperview()
        startGame()
    }
    
    func startTimer() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(timeInterval: 0.01,
                                     target:    self,
                                     selector:  #selector(ViewController.keepTimer),
                                     userInfo:  nil,
                                     repeats:   true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func checkButton(at index: Int) {
        if let buttonTitle = buttonsCollection[index].currentTitle {
            if buttonTitle == String(nextNumber) {
                buttonsCollection[index].backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 0)
                buttonsCollection[index].setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0), for: .normal)
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
            else if buttonsCollection[index].currentTitleColor == #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0)  {
                
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
