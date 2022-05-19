//
//  StatsTableViewCell.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 15.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import UIKit

class StatsTableViewCell: UITableViewCell {
    @IBOutlet weak var tableSizeView: UIView!
    @IBOutlet weak var tableSizeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var resultTimeLabel: UILabel!
    
    static let reuseId = "StatsTableViewCell"
    
    func configureCell(gameResult: GameResult) {
        let tableSize = TableSize(rawValue: Int(gameResult.tableSize))
        tableSizeLabel.text = tableSize?.string
        dateLabel.text = gameResult.date?.format
        resultTimeLabel.text = gameResult.time.formatSeconds
        
        switch TableSize(rawValue: Int(gameResult.tableSize)) {
        case .small:
            tableSizeView.backgroundColor = UIColor.theme.statsSmallColor
        case .medium:
            tableSizeView.backgroundColor = UIColor.theme.statsMediumColor
        case .big:
            tableSizeView.backgroundColor = UIColor.theme.statsBigColor
        case .huge:
            tableSizeView.backgroundColor = UIColor.theme.statsHugeColor
        default:
            print("ERROR: Unexpected table size")
        }
    }
}
