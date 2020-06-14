//
//  FavortiesManager.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation

class FavoritesManager {
    var list: [ImageInfo] {
        get {
            return self.private_list
        }
    }
    
    private var private_list: [ImageInfo] = []
    
    static var shared = FavoritesManager()
    
    var delegates: [FavortiesDelegate?] = []
    
    func update(_ new: ImageInfo) {
        if let idx = list.firstIndex(of: new) {
            self.private_list.remove(at: idx)
        } else {
            self.private_list.append(new)
        }
        delegates.forEach { a in
            a?.performFavoritesChange(new)
        }
    }
}

protocol FavortiesDelegate {
    func performFavoritesChange(_ new: ImageInfo)
}
