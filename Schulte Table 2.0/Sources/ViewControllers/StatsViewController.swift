//
//  StatsViewController.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 14.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit
import Charts

class StatsViewController: UIViewController, ChartViewDelegate {
    
    lazy var chartView: ChartView = {
        let chart = ChartView()
        return chart
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        view.addSubview(chartView)
        chartView.activateConstraints()
        setData()
    }
    
    func setChartOnView() {
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chartView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
        ])
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setData() {
        let set1 = BarChartDataSet(entries: yValues, label: "Abobus")
        let data = BarChartData(dataSet: set1)
        chartView.data = data
    }
    
    let yValues: [BarChartDataEntry] = [
        BarChartDataEntry(x: 1, y: 7),
        BarChartDataEntry(x: 2, y: 3),
        BarChartDataEntry(x: 3, y: 10),
        BarChartDataEntry(x: 4, y: 0),
        BarChartDataEntry(x: 5, y: 5),
        BarChartDataEntry(x: 6, y: 6),
        BarChartDataEntry(x: 7, y: 8),
        BarChartDataEntry(x: 8, y: 6),
        BarChartDataEntry(x: 9, y: 7),
        BarChartDataEntry(x: 10, y: 4),
        BarChartDataEntry(x: 11, y: 5),
        BarChartDataEntry(x: 12, y: 3),
    ]
}
