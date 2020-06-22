//
//  SettingsTableViewController.swift
//  ImageSearch
//
//  Created by pook on 6/13/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

// App 설정을 하는 View 입니다. 설정값은 SearchManager에게 전달됩니다.

class SettingsTableViewController: UITableViewController {
    
    
    @IBOutlet weak var deinitLogToggleBtn: UISwitch!
    
    @IBAction func deinitLogToggle(_ sender: UISwitch) {
        SettingsManager.show_deinit_log_message = sender.isOn
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.deinitLogToggleBtn.isOn = SettingsManager.show_deinit_log_message
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                InfoView.showIn(viewController: self, message: "Hi!")
                tableView.deselectRow(at: indexPath, animated: true)
            case 2:
                UIPasteboard.general.string = RealmFavoritesManager.url.path
                InfoView.showIn(viewController: self, message: "Copied!")
                tableView.deselectRow(at: indexPath, animated: true)
            case 3:
                SearchManaer.shared.request(text: "Hi", page: 1, errorHandler: {_ in}, completion: {_ in})
                tableView.deselectRow(at: indexPath, animated: true)
            default:
                ()
            }
        case 1:
            ()
        default:
            ()
        }
    }
    
}
