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
    @IBOutlet weak var selectedLanguageLabel: UILabel!
    
    var selectedSize: TableSize!
    var selectedLanguage: Language!
    var localService = LocalService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedSize = TableSize(rawValue: localService.defaultTableSize ?? 2)
        selectedLanguage = Language(rawValue: UserDefaults.languageCode ?? Locale.current.languageCode!)
        navigationItem.largeTitleDisplayMode = .always
        
        selectedLanguageLabel.text = selectedLanguage.rawValue.localized
        selectedSizeLabel.text = selectedSize.string
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            guard let sizeTableVC = storyboard?.instantiateViewController(withIdentifier: "SizeTableViewController") as? SelectorTableViewController else {
                print("Can't instantiate SizeTableViewController")
                return
            }
            sizeTableVC.someCell = SelectorTableViewCell()
            sizeTableVC.selectableValues = TableSize.allCases
            sizeTableVC.selectedIndex = IndexPath(row: selectedSize.rawValue-1, section: 0)
            // Getting data from the closure
            sizeTableVC.didSelectRow = { value in
                guard let tableSize = value as? TableSize else {
                    print("ERROR: Can't cast value into the TableSize")
                    return
                }
                self.localService.defaultTableSize = tableSize.rawValue
                self.selectedSize = tableSize
                self.selectedSizeLabel.text = tableSize.string
            }
            navigationController?.pushViewController(sizeTableVC, animated: true)
        case 1:
            guard let languageTableVC = storyboard?.instantiateViewController(withIdentifier: "LangTableViewController") as? SelectorTableViewController else {
                print("Can't instantiate LangTableViewController")
                return
            }
            languageTableVC.someCell = LanguageTableViewCell()
            languageTableVC.selectableValues = Language.allCases
            let selectedRow: Int = Language.allCases.firstIndex(of: selectedLanguage)!
            languageTableVC.selectedIndex = IndexPath(row: selectedRow, section: 0)
            languageTableVC.didSelectRow = { value in
                guard let language = value as? Language else {
                    print("ERROR: Can't cast value into the Language")
                    return
                }
                self.selectedLanguage = language
                self.selectedLanguageLabel.text = language.rawValue.localized
                Locale.updateLanguage(code: language.rawValue)
            }
            navigationController?.pushViewController(languageTableVC, animated: true)
        default:
            print("Undefined row")
        }
    }
}
