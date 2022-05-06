//
//  LanguageTableViewCell.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 06.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell, ReusableCell {
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func getReuseId() -> String {
        "LanguageTableViewCell"
    }
}


protocol ReusableCell: UITableViewCell {
    func getReuseId() -> String
}
