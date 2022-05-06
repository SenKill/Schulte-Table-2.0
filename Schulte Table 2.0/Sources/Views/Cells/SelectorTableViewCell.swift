//
//  SelectorTableViewCell.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 06.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import UIKit

class SelectorTableViewCell: UITableViewCell, ReusableCell {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func getReuseId() -> String {
        "SelectorTableViewCell"
    }
}
