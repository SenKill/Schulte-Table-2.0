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
        if indexPath.section == 0 {
            guard let GameType = GameType(rawValue: indexPath.row) else { return }
            dismiss(animated: true) { [weak self] in
                self?.didTapMenuType?(GameType)
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let alert = UIAlertController(title: "Reseting result", message: "All of your result will be deleted, are you sure?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { UIAlertAction in self.removeResult() }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        /*if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = UIColor(r: 94, g: 94, b: 94, a: 1)
            headerView.backgroundView?.backgroundColor = .black
            headerView.textLabel?.textColor = .black
        }*/
    }
    func removeResult() {
        dismiss(animated: true, completion: nil)
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "classicPrevious")
        defaults.removeObject(forKey: "classicBest")
        defaults.removeObject(forKey: "lettersPrevious")
        defaults.removeObject(forKey: "lettersBest")
        defaults.removeObject(forKey: "redblackPrevious")
        defaults.removeObject(forKey: "redblackBest")
    }
}
