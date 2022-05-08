//
//  SelectorTableViewController.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 05.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import UIKit

class SelectorTableViewController: UITableViewController {
    var didSelectRow: ((Any) -> ())?
    var selectableValues: [Any] = []
    var selectedIndex: IndexPath!
    var reuseId: String!
    var someCell: ReusableCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reuseId = someCell.getReuseId()
        navigationItem.largeTitleDisplayMode = .never
        registerCell()
    }
    
    private func registerCell() {
        let cell = UINib(nibName: reuseId, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: reuseId)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = tableView.dequeueReusableCell(withIdentifier: reuseId)
        let rawSelectedValue = selectableValues[indexPath.row]
        if selectedIndex == indexPath {
            rawCell?.accessoryType = .checkmark
        }
        
        if let cell = rawCell as? SelectorTableViewCell,
           let selectedValue = rawSelectedValue as? TableSize {
            cell.label.text = selectedValue.string
            return cell
        } else if let cell = rawCell as? LanguageTableViewCell,
                  let selectedValue = rawSelectedValue as? Language {
            cell.firstLabel.text = selectedValue.string
            cell.secondLabel.text = selectedValue.localizedString
            return cell
        }
        print("Lol(")
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex != nil {
            tableView.cellForRow(at: selectedIndex)?.accessoryType = .none
        }
        selectedIndex = indexPath
        tableView.cellForRow(at: selectedIndex)?.accessoryType = .checkmark
        tableView.deselectRow(at: selectedIndex, animated: true)
        // Providing data through the closure
        didSelectRow?(selectableValues[selectedIndex.row])
    }
}
