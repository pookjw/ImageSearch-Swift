//
//  InfoViewSettingsTableViewController.swift
//  ImageSearch
//
//  Created by pook on 6/15/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

class InfoViewSettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        self.updateCheckMark()
    }
    
    // Return the number of rows for the table.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return InfoView.ViewType.allCases.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        default:
            return ""
        }
    }
    
    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Frame"
            case 1:
                cell.textLabel?.text = "NSLayoutConstraint"
            case 2:
                cell.textLabel?.text = "SnapKit"
            default:
                ()
            }
        default:
            ()
        }
        
        return cell
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let newValue = InfoView.ViewType(rawValue: indexPath.row) else {
            fatalError("Invalid ViewType index.")
        }
        SettingsManager.infoview_type = newValue
        self.updateCheckMark()
        InfoView.showIn(viewController: self, message: "Updated!")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func updateCheckMark() {
        for n in 0..<InfoView.ViewType.allCases.count {
            let indexPath = IndexPath(row: n, section: 0)
            if SettingsManager.infoview_type.rawValue == n {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
        }
    }
    
    deinit {
        if SettingsManager.show_deinit_log_message {
            print("deinit: InfoViewSettingsTableViewController")
        }
    }

}
