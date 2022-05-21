//
//  SchulteTable.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 02.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

class SchulteTable {
    var colors: [UIColor] = []
    var titles: [String] = []
    var tableSize: TableSize!
    var letterLastTarget: Int?
    var nextTarget = 1
    
    // Red-black properties
    var redBlackLastTarget: Int {
        tableSize.items/2 + 2
    }
    lazy var targetColor: UIColor = UIColor.theme.redBlack[1]
    lazy var nextTargetRed: Int = tableSize.items / 2
    lazy var redTitles: [Int] = (1...tableSize.items/2).shuffled()
    lazy var blackTitles: [Int] = (1...tableSize.items/2 + 1).shuffled()
    lazy var redCount: Int = 0
    lazy var blackCount: Int = 0
}
