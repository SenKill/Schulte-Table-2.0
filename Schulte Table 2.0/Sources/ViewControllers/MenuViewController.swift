//
//  MenuViewController.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 8/5/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

// Side bar menu
import UIKit

enum GameType: Int {
    case classic
    case letter
    case redBlack
    case last
}

protocol MenuDelegate: AnyObject {
    func menu(didSelectGameType gameType: GameType)
    func menu(didSelectOption viewController: UIViewController)
    func menuDidResetResults()
}

class MenuViewController: UITableViewController {
    @IBOutlet weak var resetResultsLabel: UILabel!
    @IBOutlet weak var resetResultsCell: UITableViewCell!
    weak var delegate: MenuDelegate?
    
    private func handleResetting() {
        LocalService().clearAllData()
        delegate?.menuDidResetResults()
        dismiss(animated: true)
    }
}

// MARK: - TableViewDataSource
extension MenuViewController {
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .gray
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
}

// MARK: - TableViewDelegate
extension MenuViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let gameType = GameType(rawValue: indexPath.row) else { return }
            dismiss(animated: true) { [weak self] in
                self?.delegate?.menu(didSelectGameType: gameType)
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                dismiss(animated: true)
                guard let settingsViewController = storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as? SettingsTableViewController else {
                    print("Can't insantiate SettingsTableViewController")
                    return
                }
                delegate?.menu(didSelectOption: settingsViewController)
            case 1:
                dismiss(animated: true)
                guard let statsViewController = storyboard?.instantiateViewController(withIdentifier: "StatsTableViewController") as? StatsTableViewController else {
                    print("Can't insantiate StatsTableViewController")
                    return
                }
                delegate?.menu(didSelectOption: statsViewController)
            case 2:
                let alert = UIAlertController(title: "RESET_RESULTS".localized, message: "RESET_MESSAGE".localized, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "RESET_CONTINUE".localized, style: UIAlertAction.Style.default, handler: { UIAlertAction in self.handleResetting()
                }))
                alert.addAction(UIAlertAction(title: "RESET_CANCEL".localized, style: UIAlertAction.Style.cancel, handler: {_ in
                    self.resetResultsLabel.isHighlighted = false
                    self.resetResultsCell.isSelected = false
                }))
                self.present(alert, animated: true, completion: nil)
            default:
                print("Undefined row")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.theme.highlitedMenuCellColor
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.theme.menuCellColor
    }
}
