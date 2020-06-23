//
//  SettingsManager.swift
//  ImageSearch
//
//  Created by pook on 6/14/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation

// App의 설정값을 갖는 class 입니다. SettingsTableViewController에서 설정합니다.
final class SettingsManager {
    static var show_deinit_log_message: Bool = false
    static var infoview_timer: InfoView.TimerType = .two
    static var nekwork_type: SearchModel.NetworkType = .alamofire
    static var infoview_type: InfoView.ViewType = .snapkit
}
