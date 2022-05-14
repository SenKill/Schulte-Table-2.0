//
//  ChartView.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 14.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import Charts

class ChartView: BarChartView {
    
    init() {
        super.init(frame: .zero)
        rightAxis.enabled = true
        leftAxis.enabled = true
        animate(xAxisDuration: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func activateConstraints() {
        print("yes")
        guard let superview = superview else {
            print("no")
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.5),
        ])
    }
}
