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
    
    func getReuseId() -> String {
        "LanguageTableViewCell"
    }
    
    func configureCell(_ lang: Language) {
        firstLabel.text = lang.string
        secondLabel.text = lang.rawValue.localized
    }
}

protocol ReusableCell: UITableViewCell {
    func getReuseId() -> String
}
