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
    @IBOutlet weak var redDotView: UIView!
    @IBOutlet weak var buttonsCollectionView: UICollectionView!
    
    private let buttonsVC = ButtonsCollectionViewController()
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
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = String(describing: currentGameType).lowercased().localized
        
        loadDefaults()
        buttonsCollectionView.dataSource = buttonsVC
        buttonsCollectionView.delegate = buttonsVC
        buttonsVC.delegate = self
        stopwatch.delegate = self
        startGame(withType: .classic)
    }
}

// MARK: - Actions
extension HomeViewController {
    @IBAction func touchRestartButton(_ sender: UIBarButtonItem) {
        restartGame()
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
    func loadDefaults() {
        let defaults = UserDefaults.standard
        tableSize = TableSize(rawValue: localService.defaultTableSize ?? 2)
        shuffleColors = defaults.bool(forKey: UserDefaults.Key.shuffleColors)
        buttonsVC.hardMode = defaults.bool(forKey: UserDefaults.Key.hardMode)
        buttonsVC.crazyMode = defaults.bool(forKey: UserDefaults.Key.crazyMode)
        labelsView.isHidden = defaults.bool(forKey: UserDefaults.Key.hideInterface)
    }
    
    func startGame(withType gameType: GameType) {
        self.title = String(describing: gameType).localized
        let game = SchulteTable()
        game.gameType = gameType
        game.tableSize = tableSize
        game.nextTarget = 1
        game.passedButtons = []
        buttonsVC.game = game
        
        nextTargetLabel.text = String(buttonsVC.game.nextTarget)
        nextTargetLabel.textColor = .white
        
        var titles: [String] = []
        var colors: [UIColor] = shuffleColors ? getDisorderedColors(first: UIColor.theme.defaultButtons[0], second: UIColor.theme.defaultButtons[1]) : getOrderedColors(first: UIColor.theme.defaultButtons[0], second: UIColor.theme.defaultButtons[1])
        let range: ClosedRange<Int> = 1...tableSize.items
        
        switch gameType {
        case .classic:
            range.forEach { number in
                titles.append(String(number))
            }
        case .letter:
            guard tableSize != .huge && tableSize != .extraHuge else {
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
        case .redBlack:
            colors = getDisorderedColors(first: UIColor.theme.redBlack[0], second: UIColor.theme.redBlack[1])
        default:
            print("Undefined game type")
        }
        
        titles.shuffle()
        buttonsVC.game.titles = titles
        buttonsVC.game.colors = colors
        
        buttonsCollectionView.reloadSections(IndexSet(integer: 0))
        stopwatch.start()
    }
    
    func restartGame() {
        stopwatch.stop()
        startGame(withType: currentGameType)
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
        default:
            print("Undefined game type")
        }
    }
    
    func getOrderedColors(first firstColor: UIColor, second secondColor: UIColor) -> [UIColor] {
        var colors: [UIColor] = []
        var isRowEven: Bool = false
        
        if buttonsVC.game.isItemsEven {
            for i in 1...tableSize.items {
                if (!isRowEven && i%2 == 0) || (isRowEven && i%2 == 1) {
                    colors.append(firstColor)
                } else {
                    colors.append(secondColor)
                }
                if i%Int(sqrt(Double(tableSize.items))) == 0 {
                    isRowEven.toggle()
                }
            }
            return colors
        }
        
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
        navigationController?.isNavigationBarHidden = false
        labelsView.isHidden = false
        redDotView.isHidden = false
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
        if let settingsVC = viewController as? SettingsTableViewController {
            settingsVC.delegate = self
        }
        navigationController?.pushViewController(viewController, animated: false)
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
    func buttonsCollectionReloadView() {
        buttonsCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func buttonsCollection(changeTargetLabelWithText text: String, color: UIColor?) {
        nextTargetLabel.textColor = color ?? .white
        nextTargetLabel.text = text
    }
    
    func buttonsCollectionDidEndGame() {
        let statTuple = localService.handleEndGame(gameType: currentGameType, table: tableSize, timeInfo: stopwatch.getTimeInfo())
        
        stopwatch.stop()
        labelsView.isHidden = true
        redDotView.isHidden = true
        endGameView = EndGameView(frame: view.bounds.self, previous: statTuple.0, current: statTuple.1, best: statTuple.2, game: currentGameType, table: tableSize)
        navigationController?.isNavigationBarHidden = true
        view.addSubview(endGameView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEndGameView(_:)))
        endGameView.addGestureRecognizer(tapGestureRecognizer)
    }
}

// MARK: - SettingsDelegate
extension HomeViewController: SettingsDelegate {
    func settings(didChangedTableSize tableSize: TableSize) {
        if tableSize != self.tableSize {
            self.tableSize = tableSize
            restartGame()
        }
    }
    
    func settings(didChangedShuffleColors shuffleColors: Bool) {
        self.shuffleColors = shuffleColors
        restartGame()
    }
    
    func settings(didChangedHardMode hardMode: Bool) {
        buttonsVC.hardMode = hardMode
        restartGame()
    }
    
    func settings(didChangedCrazyMode crazyMode: Bool) {
        buttonsVC.crazyMode = crazyMode
        restartGame()
    }
    
    func settings(didChangedInterface hideInterface: Bool) {
        labelsView.isHidden.toggle()
    }
}
