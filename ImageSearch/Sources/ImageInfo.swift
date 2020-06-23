//
//  ImageInfo.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation
import RealmSwift

// 사진 데이터
final class ImageInfo: Object {
    @objc dynamic var display_sitename: String
    @objc dynamic var doc_url: String
    @objc dynamic var thumbnail_url: String
    @objc dynamic var image_url: String
    
    init(display_sitename: String, doc_url: String, thumbnail_url: String, image_url: String) {
        self.display_sitename = display_sitename
        self.doc_url = doc_url
        self.thumbnail_url = thumbnail_url
        self.image_url = image_url
    }
    
    required init() {
        display_sitename = ""
        doc_url = ""
        thumbnail_url = ""
        image_url = ""
    }
    
    func newRef() -> ImageInfo {
        return ImageInfo(
            display_sitename: display_sitename,
            doc_url: doc_url,
            thumbnail_url: thumbnail_url,
            image_url: image_url
        )
    }
    
    deinit {
        if SettingsManager.show_deinit_log_message {
            print("deinit: ImageInfo (\(display_sitename))")
        }
    }
}

// 이러면 Reference 비교는 못하게 되지만, 이 앱에서는 Value 비교를 원하므로...
func == (lhs: ImageInfo, rhs: ImageInfo) -> Bool {
    return (lhs.display_sitename == rhs.display_sitename) && (lhs.doc_url == rhs.doc_url) && (lhs.thumbnail_url == rhs.thumbnail_url) && (lhs.image_url == rhs.image_url)
}

