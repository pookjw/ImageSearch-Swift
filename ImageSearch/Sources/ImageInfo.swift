//
//  ImageInfo.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation

// 사진 데이터
struct ImageInfo: Decodable {
    var display_sitename: String
    var doc_url: String
    var thumbnail_url: String
    var image_url: String
    
    static func getSampleImageInfo() -> [ImageInfo] {
        let WWDC_2020 = ImageInfo(
            display_sitename: "Apple",
            doc_url: "http://apple.com",
            thumbnail_url: "https://search1.kakaocdn.net/argon/130x130_85_c/83vAVPIZ3Lg",
            image_url: "https://post-phinf.pstatic.net/MjAyMDA1MDZfNDgg/MDAxNTg4NzI3NDM2Mzcy.GIopmZ7Eqk1Lid1sqXZq9XfxZbg0q6wUBg337zj-eM8g.35sFrPTI4Zpfz0JOxUoW6NT64UcyYbnKYN_Ww83Fra0g.JPEG/apple_wwdc-announcement_ready-set-code_05052020_big.jpg.large.jpg?type=w1200"
        )
        let Phone = ImageInfo(
            display_sitename: "네이버블로그",
            doc_url: "http://blog.naver.com/hiris4/221611089087",
            thumbnail_url: "https://search3.kakaocdn.net/argon/130x130_85_c/K0YPUn9Mgn0",
            image_url: "http://postfiles3.naver.net/MjAxOTA4MDlfMjc3/MDAxNTY1MzM0MzUyOTgy.CjFwlSdhxbGg8Plc7I-3bjqjVPPvRWGORRT4gRocyw0g.XbmjQ2FmqUG8FjYca_OkIcIvE25HomfeC2EJwkV5BFog.JPEG.hiris4/55%ED%8E%9C.jpg?type=w966"
        )
        return [WWDC_2020, Phone]
    }
}

extension ImageInfo: Equatable {
    static func == (lhs: ImageInfo, rhs: ImageInfo) -> Bool {
        if (lhs.display_sitename == rhs.display_sitename) &&
            (lhs.doc_url == rhs.doc_url) &&
            (lhs.thumbnail_url == rhs.thumbnail_url) &&
            (lhs.image_url == rhs.image_url) {
            return true
        }
        return false
    }
}
