//
//  NetworkSettingsTableViewController.swift
//  ImageSearch
//
//  Created by pook on 6/14/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

final class NetworkSettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.reloadData()
        updateCheckMark()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return SearchModel.NetworkType.allCases.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Only applies on SearchViewController."
        default:
            return ""
        }
    }
    
    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            fatalError("Failed to load cell")
        }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "URLSession"
            case 1:
                cell.textLabel?.text = "Alamofire"
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
        guard let newValue = SearchModel.NetworkType(rawValue: indexPath.row) else {
            fatalError("Invalid NetworkType index.")
        }
        SettingsManager.nekwork_type = newValue
        updateCheckMark()
        InfoView.showIn(viewController: self, message: "Updated!")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func updateCheckMark() {
        for n in 0..<InfoView.TimerType.allCases.count {
            let indexPath = IndexPath(row: n, section: 0)
            if SettingsManager.nekwork_type.rawValue == n {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
        }
    }
    
    deinit {
        if SettingsManager.show_deinit_log_message {
            print("deinit: NetworkSettingsTableViewController")
        }
    }
}
