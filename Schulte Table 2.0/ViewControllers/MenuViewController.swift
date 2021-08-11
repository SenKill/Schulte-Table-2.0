//
//  MenuViewController.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 8/5/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

// Side bar menu
import UIKit

public enum GameType: Int {
    case classic
    case letter
    case redBlack
}

class MenuViewController: UITableViewController {

    var didTapMenuType: ((GameType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Menu"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let GameType = GameType(rawValue: indexPath.row) else { return }
        dismiss(animated: true) { [weak self] in
            self?.didTapMenuType?(GameType)
        }
    }
}
