//
//  ViewController.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 7/16/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import UIKit
import CoreMedia
import AVFAudio

class HomeViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var nextTargetLabel: UILabel!
    @IBOutlet var labelsView: UIView!
    @IBOutlet var restartButton: UIBarButtonItem!
    @IBOutlet weak var buttonsCollectionView: UICollectionView!
    
    private let buttonsVC = ButtonsCollectionViewController()
    private var settingsVC: SettingsTableViewController?
    private let localService = LocalService()
    private let transition = SlideInTransition()
    private let stopwatch = Stopwatch()
    private var endGameView: EndGameView!
    private var tableSize: TableSize!
    
    private var currentGameType: GameType = .classic
    private var gameResultPrevious: DefaultKeys = DefaultKeys.classicPrev
    private var gameResultBest: DefaultKeys = DefaultKeys.classicBest
    
    private var shuffleColors: Bool = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSize = TableSize(rawValue: localService.defaultTableSize ?? 2)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "classic".localized
        buttonsCollectionView.dataSource = buttonsVC
        buttonsCollectionView.delegate = buttonsVC
        buttonsVC.delegate = self
        stopwatch.delegate = self
        shuffleColors = UserDefaults.standard.bool(forKey: UserDefaults.Key.shuffleColors)
        startGame(withType: .classic)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Everytime when settings is being closed it will check the selected size
        if let size = settingsVC?.selectedSize,
           size != tableSize {
            tableSize = size
            stopwatch.stop()
            startGame(withType: currentGameType)
        }
        if let isShuffleOn = settingsVC?.shuffleColorsSwitch.isOn,
           isShuffleOn != shuffleColors {
            shuffleColors = isShuffleOn
            stopwatch.stop()
            startGame(withType: currentGameType)
        }
        super.viewWillAppear(animated)
    }
}

// MARK: - Actions
extension HomeViewController {
    @IBAction func touchRestartButton(_ sender: UIBarButtonItem) {
        stopwatch.stop()
        startGame(withType: currentGameType)
    }
    
    // Set up other game types and include them into the side bar
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        guard let menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController else { return }
        
        menuViewController.delegate = self
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnDimmingView(_:)))
        transition.dimmingView.addGestureRecognizer(gesture)
    }
}

// MARK: - Internal
private extension HomeViewController {
    func startGame(withType gameType: GameType) {
        self.title = String(describing: gameType).localized
        
        var titles: [String] = []
        var colors: [UIColor] = []
        let range = 1...tableSize.items
        
        buttonsVC.game = SchulteTable()
        buttonsVC.currentGameType = gameType
        buttonsVC.game.tableSize = tableSize
        buttonsVC.game.nextTarget = 1
        nextTargetLabel.text = String(buttonsVC.game.nextTarget)
        nextTargetLabel.textColor = .white
        
        switch gameType {
        case .classic:
            range.forEach { number in
                titles.append(String(number))
            }
            colors = shuffleColors ? getDisorderedColors(first: UIColor.theme.classicFirstColor, second: UIColor.theme.classicSecondColor) : getOrderedColors(first: UIColor.theme.classicFirstColor, second: UIColor.theme.classicSecondColor)
            
        case .letter:
            guard tableSize != .huge else {
                let alert = UIAlertController(title: "LETTER_TABLE_SIZE_TITLE".localized, message: "LETTER_TABLE_SIZE_MESSAGE".localized, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(action)
                present(alert, animated: true)
                startGame(withType: .classic)
                return
            }
            
            let smallCharacters = 97...122
            let capitalCharacters = 65...90
            
            let letterArray = Array(smallCharacters) + Array(capitalCharacters)
            for i in range {
                let letter = String(Unicode.Scalar(letterArray[i-1])!)
                titles.append(letter)
            }
            
            colors = shuffleColors ? getDisorderedColors(first: UIColor.theme.letterFirstColor, second: UIColor.theme.letterSecondColor) : getOrderedColors(first: UIColor.theme.letterFirstColor, second: UIColor.theme.letterSecondColor)
            buttonsVC.game.nextTarget = 97
            buttonsVC.game.letterLastTarget = letterArray[tableSize.items-1] + 1
            nextTargetLabel.text = String(Unicode.Scalar(buttonsVC.game.nextTarget)!)
            
        case .redBlack:
            colors = getDisorderedColors(first: UIColor.theme.redBlackFirstColor, second: UIColor.theme.redBlackSecondColor)
        }
        titles.shuffle()
        buttonsVC.game.titles = titles
        buttonsVC.game.colors = colors
        
        buttonsCollectionView.reloadSections(IndexSet(integer: 0))
        stopwatch.start()
    }
    
    func transitionToNew(_ gameType: GameType) {
        stopwatch.stop()
        switch gameType {
        case .classic:
            self.currentGameType = .classic
            startGame(withType: .classic)
            gameResultPrevious = DefaultKeys.classicPrev
            gameResultBest = DefaultKeys.classicBest
            
        case .letter:
            self.currentGameType = .letter
            startGame(withType: .letter)
            gameResultPrevious = DefaultKeys.lettersPrev
            gameResultBest = DefaultKeys.lettersBest
            
        case .redBlack:
            self.currentGameType = .redBlack
            startGame(withType: .redBlack)
            gameResultPrevious = DefaultKeys.lettersPrev
            gameResultBest = DefaultKeys.lettersBest
        }
    }
    
    func getOrderedColors(first firstColor: UIColor, second secondColor: UIColor) -> [UIColor] {
        var colors: [UIColor] = []
        
        for i in 1...tableSize.items {
            if i%2 == 0 {
                colors.append(firstColor)
            } else {
                colors.append(secondColor)
            }
        }
        return colors
    }
    
    func getDisorderedColors(first firstColor: UIColor, second secondColor: UIColor) -> [UIColor] {
        var colors: [UIColor] = []
        let isNumberEven: Bool = tableSize.items % 2 == 0
        let firstRange = 1...(tableSize.items / 2)
        let secondRange = 1...(isNumberEven ? tableSize.items / 2 : tableSize.items / 2 + 1)
        
        for _ in firstRange {
            colors.append(firstColor)
        }
        for _ in secondRange {
            colors.append(secondColor)
        }
        return colors.shuffled()
    }
}

// MARK: - Obj-C functions
private extension HomeViewController {
    @objc func didTapOnDimmingView(_ sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapEndGameView(_ sender: UITapGestureRecognizer) {
        endGameView.removeFromSuperview()
        if let navigationController = navigationController {
            view.addSubview(navigationController.navigationBar)
        }
        labelsView.isHidden = false
        startGame(withType: currentGameType)
    }
}

// MARK: TransitionDelegate
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

// MARK: StopwatchDelegate
extension HomeViewController: StopwatchDelegate {
    func stopwatch(secondsDidChanged seconds: Int) {
        timeLabel.text = "\(seconds)"
    }
}

// MARK: - MenuDelegate
extension HomeViewController: MenuDelegate {
    func menu(didSelectOption viewController: UIViewController) {
        guard let navControl = navigationController else {
            print("ERROR: Can't find navigationController")
            return
        }
        navControl.pushViewController(viewController, animated: true)
    }
    
    func menuDidSelectSettings() {
        guard let settingsViewController = storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as? SettingsTableViewController else {
            print("Can't insantiate SettingsTableViewController")
            return
        }
        settingsVC = settingsViewController
        if let navControl = navigationController {
            navControl.pushViewController(settingsVC!, animated: false)
        }
    }
    
    func menuDidResetResults() {
        stopwatch.stop()
        startGame(withType: currentGameType)
    }
    
    func menu(didSelectGameType gameType: GameType) {
        transitionToNew(gameType)
    }
}

// MARK: - ButtonsCollectionDelegate
extension HomeViewController: ButtonsCollectionDelegate {
    func buttonsCollection(changeTargetLabelWithText text: String, color: UIColor?) {
        nextTargetLabel.textColor = color ?? .white
        nextTargetLabel.text = text
    }
    
    func buttonsCollectionDidEndGame() {
        let statTuple = localService.handleEndGame(gameType: currentGameType, table: tableSize, timeInfo: stopwatch.getTimeInfo())
        
        stopwatch.stop()
        labelsView.isHidden = true
        endGameView = EndGameView(frame: view.bounds.self, previous: statTuple.0, current: statTuple.1, best: statTuple.2, game: currentGameType, table: tableSize)
        navigationController?.navigationBar.removeFromSuperview()
        
        view.addSubview(endGameView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEndGameView(_:)))
        endGameView.addGestureRecognizer(tapGestureRecognizer)
    }
}
