//
//  SizeTableViewController.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 03.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

class SizeTableViewController: UITableViewController {
    var didSelectSize: ((TableSize) -> ())?
    private let tableSizes: [TableSize] = [TableSize.small, TableSize.medium, TableSize.big, TableSize.huge]
    var selectedIndex: IndexPath!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
            self.checkCells()
        }
    }
    
    func checkCells() {
        for i in 0..<tableSizes.count {
            let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0))
            if i == selectedIndex.row {
                cell?.accessoryType = .checkmark
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex != nil {
            tableView.cellForRow(at: selectedIndex)?.accessoryType = .none
        }
        selectedIndex = indexPath
        tableView.cellForRow(at: selectedIndex)?.accessoryType = .checkmark
        tableView.deselectRow(at: selectedIndex, animated: true)
        // Providing data through the closure
        didSelectSize?(tableSizes[indexPath.row])
    }
}
