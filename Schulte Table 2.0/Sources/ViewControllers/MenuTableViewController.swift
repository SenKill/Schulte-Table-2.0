//
//  MenuTableViewController.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 8/5/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

// Side bar menu
import UIKit

enum GameType: Int, CaseIterable {
    case classic
    case letter
    case redBlack
}

protocol MenuDelegate: AnyObject {
    func menu(didSelectGameType gameType: GameType)
    func menu(didSelectOption viewController: UIViewController)
    func menuDidResetResults()
}

final class MenuTableViewController: UITableViewController {
    // MARK: - Public vars
    weak var delegate: MenuDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet private weak var resetResultsLabel: UILabel!
    @IBOutlet private weak var resetResultsCell: UITableViewCell!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

// MARK: - TableViewDataSource
extension MenuTableViewController {
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        // Menu headerView
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .secondaryLabel
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
}

// MARK: - TableViewDelegate
extension MenuTableViewController {
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
                let statsViewController = StatsTableViewController()
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
}

// MARK: - Internal
private extension MenuTableViewController {
    func handleResetting() {
        LocalService().clearAllData()
        delegate?.menuDidResetResults()
        dismiss(animated: true)
    }
}
