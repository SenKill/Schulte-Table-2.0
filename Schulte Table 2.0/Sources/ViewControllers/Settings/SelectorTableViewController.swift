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
           let selectedTableSize = rawSelectedValue as? TableSize {
            cell.label.text = selectedTableSize.string
            return cell
        } else if let cell = rawCell as? LanguageTableViewCell,
                  let selectedLanguage = rawSelectedValue as? Language {
            cell.configureCell(selectedLanguage)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: selectedIndex)?.accessoryType = .none
        selectedIndex = indexPath
        tableView.deselectRow(at: selectedIndex, animated: true)
        tableView.cellForRow(at: selectedIndex)?.accessoryType = .checkmark
        // Providing data through the closure
        didSelectRow?(selectableValues[selectedIndex.row])
    }
}
