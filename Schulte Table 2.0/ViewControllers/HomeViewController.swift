//
//  ViewController.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 7/16/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import UIKit
import AVFoundation

struct DefaultKeys {
    static let keyOne = "previousResult"
    static let keyTwo = "bestResult"
}

class HomeViewController: UIViewController {
    
    let transition = SlideInTransition()
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var nextTargetLabel: UILabel!
    @IBOutlet var buttonsCollection: [UIButton]!
    @IBOutlet var labelsView: UIView!
    @IBOutlet var restartButton: UIBarButtonItem!
    
    var endGameView: UIView?
    var currentResult: Double?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var audioPlayer: AVAudioPlayer?
    
    var timer: Timer?
    var (seconds, fractions) = (0, 0)
    var nextTarget = 1
    var lastGameType: GameType = .classic
    
    @IBAction func touchButton(_ sender: UIButton) {
        if let buttonNumber = buttonsCollection.firstIndex(of: sender) {
           checkButton(at: buttonNumber)
        }
    }
    
    @IBAction func touchRestartButton(_ sender: UIBarButtonItem) {
        stopTimer()
        startGame(withType: .classic)
    }
    
    // Side bar menu
    // Set up other game types and include they into side bar
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        guard let menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController else { return }
        menuViewController.didTapMenuType = { GameType in
            self.transitionToNew(GameType)
        }
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
    }
    
    func transitionToNew(_ GameType: GameType) {
        let title = String(describing: GameType).capitalized
        self.title = title
        
        switch GameType {
            case .classic:
                lastGameType = .classic
                startGame(withType: .classic)
            case .letter:
                lastGameType = .letter
                startGame(withType: .letter)
            case .redBlack:
                lastGameType = .redBlack
                startGame(withType: .redBlack)
            default:
                break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGame(withType: .classic)
    }
    
    func startGame(withType gameType: GameType) {
        // TODO: Change design of the application
        
        seconds = 0
        fractions = 0
        
        let range = 1...25
        labelsView.isHidden = false
        var button: UIButton
        
        switch gameType {
        case .classic:
            let buttonNum = range.shuffled()
            
            for i in range {
                button = buttonsCollection[i-1]
                button.setTitle(String(buttonNum[i-1]), for: .normal)
            }
            nextTarget = 1
            nextTargetLabel.text = String(nextTarget)
            
        case .letter:
            let rangeOfLetterNumbers = 97...121
            let letterNumbers = rangeOfLetterNumbers.shuffled()
            for i in range {
                let letter = Unicode.Scalar(letterNumbers[i-1])!
                button = buttonsCollection[i-1]
                button.setTitle(String(letter), for: .normal)
            }
            nextTarget = 97
            nextTargetLabel.text = String(Unicode.Scalar(nextTarget)!)
            
        case .redBlack:
            // TODO: Make red-black game type
            break
        default:
            print("Error this game type doesn't exist")
            break
        }
        
        
        for i in 0..<buttonsCollection.count {
            buttonsCollection[i].setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            if i%2 == 0 {
                buttonsCollection[i].backgroundColor = UIColor(r: 107, g: 144, b: 128, a: 1)
            }
            else {
                buttonsCollection[i].backgroundColor = UIColor(r: 164, g: 195, b: 178, a: 1)
            }
        }
        startTimer()
    }
    
    func endGame() {
        // TODO: Turn the navigation bar on dark too
        // TODO: Make best and previous result for other game types
        
        currentResult = convertTimeToDouble(yourSeconds: seconds, yourFractions: fractions)
        
        stopTimer()
        
        labelsView.isHidden = true
        
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
        startGame(withType: lastGameType)
    }
    
    func startTimer() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(timeInterval: 0.01,
                                     target:    self,
                                     selector:  #selector(HomeViewController.keepTimer),
                                     userInfo:  nil,
                                     repeats:   true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func checkButton(at index: Int) {
        if let buttonTitle = buttonsCollection[index].currentTitle {
            if buttonTitle == String(nextTarget) || buttonTitle == String(Unicode.Scalar(nextTarget)!) {
                buttonsCollection[index].backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 0)
                buttonsCollection[index].setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0), for: .normal)
                let pathToSound = Bundle.main.path(forResource: "correct", ofType: "wav")
                let url = URL(fileURLWithPath: pathToSound!)
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                } catch {
                    
                }
                nextTarget += 1
                if nextTarget == 26 || nextTarget == 122 {
                    endGame()
                }
                else if nextTarget > 26 {
                    nextTargetLabel.text = String(Unicode.Scalar(nextTarget)!)
                }
                else {
                    nextTargetLabel.text = String(nextTarget)
                }
            }
            else if buttonsCollection[index].currentTitleColor == #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0)  { }
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
        seconds += fractions / 100
        fractions %= 100
        
        timeLabel.text = "\(seconds)"
    }
}

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

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
}
