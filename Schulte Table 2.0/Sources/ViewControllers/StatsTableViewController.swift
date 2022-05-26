//
//  StatsTableViewController.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 15.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class StatsTableViewController: UITableViewController {
    private var records: [GameType: [GameResult]] = [:]
    private let coreDataStack = CoreDataStack.shared
    
    private let sectionHeaderHeigh: CGFloat = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(named: "SecondaryColor")!
        tableView.rowHeight = 50
        title = "STATS".localized
        registerCell()
        sortRecords(rawRecords: fetchRecords())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - Internal
private extension StatsTableViewController {
    func registerCell() {
        let cell = UINib(nibName: StatsTableViewCell.reuseId, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: StatsTableViewCell.reuseId)
    }
    
    func fetchRecords() -> [GameResult] {
        let fetchRequest: NSFetchRequest<GameResult> = GameResult.fetchRequest()
        do {
            let data = try coreDataStack.managedContext.fetch(fetchRequest)
            return data
        } catch let error as NSError {
            print("Failed to load game records: \(error), \(error.userInfo)")
        }
        return []
    }
    
    // Sorting data from the rawRecords to the more readable 'records' dictionary, to easily set sections for table
    func sortRecords(rawRecords: [GameResult]) {
        records[.classic] = rawRecords.filter({ $0.gameType == GameType.classic.rawValue })
        records[.letter] = rawRecords.filter({ $0.gameType == GameType.letter.rawValue })
        records[.redBlack] = rawRecords.filter({ $0.gameType == GameType.redBlack.rawValue })
    }
}

// MARK: TableDataSource
extension StatsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        GameType.last.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = GameType(rawValue: section), let recordData = records[section] {
            return recordData.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatsTableViewCell.reuseId, for: indexPath) as? StatsTableViewCell else {
            return UITableViewCell()
        }
        if let gameType = GameType(rawValue: indexPath.section), let gameResult = records[gameType] {
            cell.configureCell(gameResult: gameResult[indexPath.row])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sectionHeaderHeigh))
        view.backgroundColor = UIColor.theme.secondary
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: sectionHeaderHeigh))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .label
        if let gameType = GameType(rawValue: section) {
            switch gameType {
            case .classic:
                label.text = String(describing: GameType.classic).localized
            case .letter:
                label.text = String(describing: GameType.letter).localized
            case .redBlack:
                label.text = String(describing: GameType.redBlack).localized
            default:
                print("Undefined gameType")
            }
        }
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let gameType = GameType(rawValue: section), let record = records[gameType], record.count > 0 {
            return sectionHeaderHeigh
        }
        return 0
    }
}

// MARK: - TableViewDelegate
extension StatsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gameTypeRecords: [GameResult] = records[GameType(rawValue: indexPath.section)!] ?? []
        let currentTableSize = gameTypeRecords[indexPath.row].tableSize
        let currentTableRecords: [GameResult] = gameTypeRecords.filter({ $0.tableSize == currentTableSize})
        let chartVC = ChartViewController(gameResults: currentTableRecords)
        chartVC.modalPresentationStyle = .automatic
        
        present(chartVC, animated: true)
    }
}
