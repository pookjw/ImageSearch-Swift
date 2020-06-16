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
class ImageInfo: Object {
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
        self.display_sitename = ""
        self.doc_url = ""
        self.thumbnail_url = ""
        self.image_url = ""
    }
}

// 이러면 Reference 비교는 못하게 되지만, 이 앱에서는 Value 비교를 원하므로...
func == (lhs: ImageInfo, rhs: ImageInfo) -> Bool {
    return true
}

