//
//  FavortiesManager.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation

// 즐겨찾기를 관리하는 class 입니다.
// RxSwift의 Observable을 쓰면 안 되어서, 각 View에서 들어오는 ImageInfo를 어떻게 한꺼번에 처리할 수 있을까를 생각하다가, Delegate를 써보자고 생각했습니다.
// 중요: 즐겨찾기를 추가하거나 제거하려면 반드시 update(_:)를 써야 합니다. list를 직접적으로 수정하면 안 됩니다. 그래서 list는 get-only로 설정했습니다.
// update(_:)에 ImageInfo 값을 전달하면, 이미 favorited 되어 있으면 삭제하고, 아니면 추가하는 식으로 자동으로 작동합니다. method를 부를 때 추가와 삭제를 구분할 필요없이 update(_:)만 하면 자동으로 처리됩니다.
// View를 시작할 때 viewDidLoad에서 FavoritesManager.shared.delegates에 self를 추가해야 합니다. 또한 해당 View는 FavortiesDelegate를 conform 해야 합니다.

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
