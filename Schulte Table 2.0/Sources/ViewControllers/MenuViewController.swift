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
}

protocol MenuDelegate: AnyObject {
    func menu(didSelectGameType gameType: GameType)
    func menuDidResetResults()
    func menuDidSelectSettings()
}

class MenuViewController: UITableViewController {
    
    @IBOutlet weak var resetResultsLabel: UILabel!
    
    weak var delegate: MenuDelegate?
    
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
                delegate?.menuDidSelectSettings()
            case 1:
                let alert = UIAlertController(title: "RESET_RESULTS".localized, message: "RESET_MESSAGE".localized, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "RESET_CONTINUE".localized, style: UIAlertAction.Style.default, handler: { UIAlertAction in self.handleResetting()
                }))
                alert.addAction(UIAlertAction(title: "RESET_CANCEL".localized, style: UIAlertAction.Style.cancel, handler: {_ in
                    self.resetResultsLabel.isHighlighted = false
                }))
                self.present(alert, animated: true, completion: nil)
            default:
                print("Undefined row")
            }
        }
    }
    
    private func handleResetting() {
        LocalService().clearAllData()
        delegate?.menuDidResetResults()
        dismiss(animated: true)
    }
}
