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

final class HomeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var nextTargetLabel: UILabel!
    @IBOutlet private weak var labelsView: UIView!
    @IBOutlet private weak var redDotView: UIView!
    @IBOutlet private weak var buttonsCollectionView: UICollectionView!
    
    // MARK: - Properties
    private let buttonsViewController = ButtonsCollectionViewController()
    private let localService = LocalService()
    private let transition = SlideInTransition()
    private let stopwatch = Stopwatch()
    private var currentGameType: GameType = .classic
    private var shuffleColors: Bool = false
    private var endGameView: EndGameView!
    private var tableSize: TableSize!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        loadDefaults()
        setDelegates()
        startGame(withType: .classic)
        configureSwipeGesRec()
    }
    
    // MARK: - IBActions
    @IBAction func didTapRestart(_ sender: UIBarButtonItem) {
        restartGame()
    }
    
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        startMenuTranstition()
    }
}

// MARK: - Internal
private extension HomeViewController {
    func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = String(describing: currentGameType).lowercased().localized
    }
    
    func setDelegates() {
        buttonsCollectionView.dataSource = buttonsViewController
        buttonsCollectionView.delegate = buttonsViewController
        stopwatch.delegate = self
    }
    
    func startMenuTranstition() {
        guard let menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuTableViewController") as? MenuTableViewController else { return }
        menuViewController.delegate = self
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnDimmingView(_:)))
        transition.dimmingView.addGestureRecognizer(gesture)
    }
    
    func loadDefaults() {
        let defaults = UserDefaults.standard
        tableSize = TableSize(rawValue: localService.defaultTableSize ?? 2)
        shuffleColors = defaults.bool(forKey: UserDefaults.Key.shuffleColors)
        buttonsViewController.hardMode = defaults.bool(forKey: UserDefaults.Key.hardMode)
        buttonsViewController.crazyMode = defaults.bool(forKey: UserDefaults.Key.crazyMode)
        labelsView.isHidden = defaults.bool(forKey: UserDefaults.Key.hideInterface)
        redDotView.isHidden = defaults.bool(forKey: UserDefaults.Key.hideRedDot)
    }
    
    func startGame(withType gameType: GameType) {
        self.currentGameType = gameType
        self.title = String(describing: gameType).localized
        let game = GameInfo(gameType: gameType, tableSize: tableSize, shuffleColors: shuffleColors) {
            let alert = UIAlertController(title: "LETTER_TABLE_SIZE_TITLE".localized, message: "LETTER_TABLE_SIZE_MESSAGE".localized, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
        game.delegate = self
        
        if game.titles.isEmpty {
            self.startGame(withType: .classic)
            return
        }
        
        nextTargetLabel.text = game.firstTarget
        nextTargetLabel.textColor = .white
        buttonsViewController.game = game
        buttonsCollectionView.reloadSections(IndexSet(integer: 0))
        stopwatch.start()
    }
    
    func restartGame() {
        stopwatch.stop()
        startGame(withType: currentGameType)
    }
    
    func transitionToNew(_ gameType: GameType) {
        stopwatch.stop()
        startGame(withType: gameType)
    }
    
    func configureSwipeGesRec() {
        let swipeGesRec = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeOnRight))
        view.addGestureRecognizer(swipeGesRec)
    }
}

// MARK: - Obj-C functions
private extension HomeViewController {
    @objc func didTapOnDimmingView(_ sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapEndGameView(_ sender: UITapGestureRecognizer) {
        endGameView.removeFromSuperview()
        endGameView = nil
        navigationController?.isNavigationBarHidden = false
        
        let defaults = UserDefaults.standard
        labelsView.isHidden = defaults.bool(forKey: UserDefaults.Key.hideInterface)
        redDotView.isHidden = defaults.bool(forKey: UserDefaults.Key.hideRedDot)
        startGame(withType: currentGameType)
    }
    
    @objc func didSwipeOnRight(_ sender: UISwipeGestureRecognizer) {
        if sender.location(in: view).x < view.bounds.midX {
            startMenuTranstition()
        }
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

// MARK: - GameInfoDelegate
extension HomeViewController: GameInfoDelegate {
    func gameInfoReloadView() {
        buttonsCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func gameInfo(changeTargetLabelWithText text: String, color: UIColor?) {
        nextTargetLabel.textColor = color ?? .white
        nextTargetLabel.text = text
    }
    
    func gameInfoDidEndGame() {
        let statistics = localService.handleEndGame(gameType: currentGameType, table: tableSize, timeInfo: stopwatch.getTimeInfo())
        stopwatch.stop()
        labelsView.isHidden = true
        redDotView.isHidden = true
        navigationController?.isNavigationBarHidden = true
        endGameView = EndGameView(frame: view.bounds.self, statistics: statistics, game: currentGameType, table: tableSize)
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
        buttonsViewController.hardMode = hardMode
        restartGame()
    }
    
    func settings(didChangedCrazyMode crazyMode: Bool) {
        buttonsViewController.crazyMode = crazyMode
        restartGame()
    }
    
    func settings(didChangedInterface hideInterface: Bool) {
        labelsView.isHidden.toggle()
    }
    
    func settings(didChangedRedDot hideRedDot: Bool) {
        redDotView.isHidden.toggle()
    }
}
