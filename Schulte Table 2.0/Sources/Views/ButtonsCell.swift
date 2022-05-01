//
//  ButtonsCell.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 29.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

class ButtonsCell: UICollectionViewCell {
    static let reuseId = "ButtonsCell"
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func didTapButton(_ sender: UIButton) {
        handleButtonAction?(sender)
    }
    
    var handleButtonAction: ((UIButton) -> Void)?
    
    func configureCell(with name: String, color: UIColor) {
        button.isHidden = false
        button.setTitle(name, for: .normal)
        button.backgroundColor = color
    }
}
