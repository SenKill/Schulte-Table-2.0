//
//  SettingsTableViewController.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 03.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import UIKit

protocol SettingsDelegate: AnyObject {
    func settings(didChangedTableSize grid: TableSize)
    func settings(didChangedShuffleColors shuffleColors: Bool)
    func settings(didChangedHardMode hardMode: Bool)
    func settings(didChangedCrazyMode crazyMode: Bool)
    func settings(didChangedInterface hideInterface: Bool)
}

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var selectedSizeLabel: UILabel!
    @IBOutlet weak var selectedLanguageLabel: UILabel!
    @IBOutlet weak var shuffleColorsSwitch: UISwitch!
    @IBOutlet weak var hardModeSwitch: UISwitch!
    @IBOutlet weak var crazyModeSwitch: UISwitch!
    @IBOutlet weak var interfaceSwitch: UISwitch!
    @IBOutlet weak var vibrationSwitch: UISwitch!
    
    weak var delegate: SettingsDelegate?
    
    private var selectedSize: TableSize!
    private var selectedLanguage: Language!
    private var localService = LocalService()
    private let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDefaults()
        navigationItem.largeTitleDisplayMode = .always
        
        selectedLanguageLabel.text = selectedLanguage.rawValue.localized
        selectedSizeLabel.text = selectedSize.string
    }
}

// MARK: - Actions
extension SettingsTableViewController {
    @IBAction func didSwitchShuffleColors(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: UserDefaults.Key.shuffleColors)
        delegate?.settings(didChangedShuffleColors: sender.isOn)
    }
    
    @IBAction func didSwitchHardMode(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: UserDefaults.Key.hardMode)
        delegate?.settings(didChangedHardMode: sender.isOn)
    }
    
    @IBAction func didSwitchCrazyMode(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: UserDefaults.Key.crazyMode)
        delegate?.settings(didChangedCrazyMode: sender.isOn)
    }
    
    @IBAction func didSwitchInterfaceSwitch(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: UserDefaults.Key.hideInterface)
        delegate?.settings(didChangedInterface: sender.isOn)
    }
    
    @IBAction func didSwitchVibration(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: UserDefaults.Key.vibration)
        let center = NotificationCenter.default
        center.post(name: .vibration, object: sender.isOn)
    }
}

// MARK: - Internal
private extension SettingsTableViewController {
    func loadDefaults() {
        selectedSize = TableSize(rawValue: localService.defaultTableSize ?? 2)
        selectedLanguage = Language(rawValue: UserDefaults.languageCode ?? Locale.current.languageCode!)
        shuffleColorsSwitch.isOn = defaults.bool(forKey: UserDefaults.Key.shuffleColors)
        hardModeSwitch.isOn = defaults.bool(forKey: UserDefaults.Key.hardMode)
        crazyModeSwitch.isOn = defaults.bool(forKey: UserDefaults.Key.crazyMode)
        interfaceSwitch.isOn = defaults.bool(forKey: UserDefaults.Key.hideInterface)
        vibrationSwitch.isOn = defaults.bool(forKey: UserDefaults.Key.vibration)
    }
}

// MARK: - TableViewDelegate
extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        // MARK: - GridSize
        case IndexPath(item: 0, section: 0):
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
                self.delegate?.settings(didChangedTableSize: tableSize)
            }
            navigationController?.pushViewController(sizeTableVC, animated: true)
        // MARK: - Language
        case IndexPath(item: 1, section: 0):
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
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.theme.highlightedCell
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.theme.primary
    }
}
