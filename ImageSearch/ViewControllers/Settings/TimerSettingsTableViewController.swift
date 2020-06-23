//
//  TimerSettingsTableViewController.swift
//  ImageSearch
//
//  Created by pook on 6/13/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

// InfoView의 Timer를 설정하는 View 입니다. 설정값은 SearchManager에게 전달됩니다.

class TimerSettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
            return InfoView.TimerType.allCases.count
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
            return """
            Description:
            - `Timer.scheduledTimer with withTimeInterval: 1.0` repeats 3 times, so InfoView will disappear after 3 seconds.
            - `DispatchQueue.glocal().async` sleeps during 3 seconds on global Thread, then InfoView will disappear.
            """
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
                cell.textLabel?.text = "Timer.scheduledTimer with withTimeInterval: 1.0"
            case 1:
                cell.textLabel?.text = "Timer.scheduledTimer with withTimeInterval: 3.0"
            case 2:
                cell.textLabel?.text = "DispatchQueue.global().asyncAfter"
            case 3:
                cell.textLabel?.text = "perform with afterDelay: 3.0"
            case 4:
                cell.textLabel?.text = "DispatchQueue.glocal().async"
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
        guard let newValue = InfoView.TimerType(rawValue: indexPath.row) else {
            fatalError("Invalid TimerType index.")
        }
        SettingsManager.infoview_timer = newValue
        self.updateCheckMark()
        InfoView.showIn(viewController: self, message: "Updated to a new Timer!")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func updateCheckMark() {
        for n in 0..<InfoView.TimerType.allCases.count {
            let indexPath = IndexPath(row: n, section: 0)
            if SettingsManager.infoview_timer.rawValue == n {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
        }
    }
    
    deinit {
        if SettingsManager.show_deinit_log_message {
            print("deinit: TimerSettingsTableViewController")
        }
    }
}
