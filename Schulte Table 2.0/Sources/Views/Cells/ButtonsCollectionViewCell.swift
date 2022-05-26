//
//  ButtonsCell.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 29.04.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

class ButtonsCollectionViewCell: UICollectionViewCell {
    static let reuseId = "ButtonsCollectionViewCell"
    
    @IBOutlet weak var button: UIButton!
    @IBAction func didTapButton(_ sender: UIButton) {
        handleButtonAction?(sender)
    }
    
    var handleButtonAction: ((UIButton) -> Void)?
    
    func configureCell(with name: String, color: UIColor, crazyMode: Bool = false) {
        button.setTitle(name, for: .normal)
        button.backgroundColor = color
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 15
        
        if crazyMode, let randomColor = UIColor.theme.crazyModeTitles.randomElement() {
            button.setTitleColor(randomColor, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        button.isHidden = false
        button.setTitleColor(.white, for: .normal)
    }
}
