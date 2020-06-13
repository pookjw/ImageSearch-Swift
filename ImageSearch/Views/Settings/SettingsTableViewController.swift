//
//  SettingsTableViewController.swift
//  ImageSearch
//
//  Created by pook on 6/13/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                InfoView.showIn(viewController: self, message: "Hi!")
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
