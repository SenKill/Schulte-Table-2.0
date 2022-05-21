//
//  ChartView.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 14.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import Charts

class ChartView: LineChartView {
    init() {
        super.init(frame: .zero)
        customizeChartView()
        legend.verticalAlignment = .top
        legend
        backgroundColor = .systemBackground
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func activateConstraints() {
        guard let superview = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: 150)
        ])
    }
    
    func setLimitLine(limit: Double) {
        let limitLine = ChartLimitLine(limit: limit)
        limitLine.lineWidth = 4
        limitLine.lineDashLengths = [5, 5]
        limitLine.labelPosition = .rightTop
        limitLine.valueFont = .systemFont(ofSize: 10)
        
        leftAxis.addLimitLine(limitLine)
        leftAxis.axisMinimum = 0
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = false
    }
}

private extension ChartView {
    func customizeChartView() {
        rightAxis.enabled = true
        leftAxis.enabled = true
        xAxis.enabled = true
        gridBackgroundColor = .black
    }
}
