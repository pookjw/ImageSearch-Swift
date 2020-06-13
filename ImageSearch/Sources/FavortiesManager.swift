//
//  FavortiesManager.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation

class FavoritesManager {
    static var list: [ImageInfo] = []
    static var delegates: [FavortiesDelegate] = []
    static func update(_ new: ImageInfo) {
        if let idx = list.firstIndex(of: new) {
            list.remove(at: idx)
        } else {
            list.append(new)
        }
        delegates.forEach { a in
            a.performFavoritesChange(new)
        }
    }
}

protocol FavortiesDelegate {
    func performFavoritesChange(_ new: ImageInfo)
}
