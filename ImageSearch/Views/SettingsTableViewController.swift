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
        InfoView.showIn(viewController: self, message: "Welcome!")
    }



    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                InfoView.showIn(viewController: self, message: "Test")
                //tableView.deselectRow(at: indexPath, animated: true)
            default:
                ()
            }
        }
    }

}
