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
    
    func getReuseId() -> String {
        "SelectorTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView()
        view.backgroundColor = UIColor.theme.highlightedCell
        selectedBackgroundView = view
    }
}
