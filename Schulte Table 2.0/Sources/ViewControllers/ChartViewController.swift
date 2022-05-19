//
//  ChartViewController.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 14.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit
import Charts

class ChartViewController: UIViewController {
    private let chartView = ChartView()
    private let records: [GameResult]
    private var tableSize: TableSize!
    private var gameType: GameType!
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(gameResults: [GameResult]) {
        records = gameResults
        tableSize = TableSize(rawValue: Int(gameResults[0].tableSize))
        gameType = GameType(rawValue: Int(gameResults[0].gameType))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        records = []
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(cancelButton)
        layoutViews()
        cancelButton.addTarget(self, action: #selector(didTapCancelButton(_:)), for: .touchUpInside)
        view.addSubview(chartView)
        chartView.activateConstraints()
        createDataSets()
    }
}

// MARK: - Internal
private extension ChartViewController {
    func createDataSets() {
        let dataSet = BarChartDataSet()
        dataSet.colors = tableSize.statsColors
        dataSet.label = "\(tableSize.string), \(String(describing: gameType!).localized)"
        
        for i in 0..<records.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: records[i].time)
            dataSet.append(dataEntry)
        }
        
        let chartData = BarChartData(dataSet: dataSet)
        chartView.data = chartData
    }
    
    func layoutViews() {
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func didTapCancelButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - ChartViewDelegate
extension ChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
}
