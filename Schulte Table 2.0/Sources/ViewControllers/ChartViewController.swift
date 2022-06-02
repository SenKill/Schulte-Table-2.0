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
        
        button.setTitle("CLOSE".localized, for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont(name: "Gill Sans SemiBold", size: 20)
        
        button.backgroundColor = .systemBackground
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.cornerRadius = 20
        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        button.layer.masksToBounds = false
        button.setTitleColor(UIColor.secondaryLabel, for: .highlighted)
        
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
        view.backgroundColor = .clear
        view.addSubview(chartView)
        view.addSubview(cancelButton)
        
        chartView.activateConstraints()
        layoutViews()
        createDataSets()
        cancelButton.addTarget(self, action: #selector(didTapCancelButton(_:)), for: .touchUpInside)
    }
}

// MARK: - Internal
private extension ChartViewController {
    func createDataSets() {
        let dataSet = LineChartDataSet()
        
        dataSet.colors = tableSize.statsColors
        dataSet.setColor(tableSize.statsColors[0])
        dataSet.highlightColor = .systemRed
        dataSet.mode = .cubicBezier
        dataSet.lineWidth = 3
        dataSet.fill = ColorFill(color: tableSize.statsColors[0])
        dataSet.fillAlpha = 0.7
        dataSet.circleColors = [.label]
        dataSet.drawFilledEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.circleRadius = 3
        
        dataSet.label = "\(tableSize.string), \(String(describing: gameType!).localized)"
        
        var averageResult: Double = 0
        for i in 0 ..< records.count {
            // Finding average result value
            averageResult += records[i].time
            
            let dataEntry = ChartDataEntry(x: Double(i), y: records[i].time)
            dataSet.append(dataEntry)
        }
        averageResult /= Double(records.count)
        // Setting limitLine's limit that located in the ChartView
        chartView.setLimitLine(limit: averageResult)
        
        let chartData = LineChartData(dataSet: dataSet)
        chartView.data = chartData
    }
    
    func layoutViews() {
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 90),
            cancelButton.bottomAnchor.constraint(equalTo: chartView.topAnchor, constant: -10),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
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
