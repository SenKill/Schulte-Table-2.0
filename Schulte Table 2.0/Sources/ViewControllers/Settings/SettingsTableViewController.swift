//
//  SettingsTableViewController.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 03.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var selectedSizeLabel: UILabel!
    var selectedSize: TableSize = .medium
    var localService = LocalService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        selectedSizeLabel.text = selectedSize.name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            guard let sizeTableVC = storyboard?.instantiateViewController(withIdentifier: "SizeTableViewController") as? SizeTableViewController else {
                print("Can't instantiate SizeTableViewController")
                return
            }
            sizeTableVC.selectedIndex = IndexPath(row: selectedSize.rawValue, section: 0)
            // Getting data from the closure
            sizeTableVC.didSelectSize = { tableSize in
                self.selectedSize = tableSize
                self.selectedSizeLabel.text = tableSize.name
            }
            navigationController?.pushViewController(sizeTableVC, animated: true)
        default:
            print("Undefined row")
        }
    }
}
