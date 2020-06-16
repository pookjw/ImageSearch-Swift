//
//  RealmManager.swift
//  ImageSearch
//
//  Created by pook on 6/15/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    //
    
    static let url: URL = {
        do {
            guard let doc_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw RealmManagerError.FailedToFindDocumentDirectory
            }
            return doc_url.appendingPathComponent("UserData.realm")
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    let realm: Realm?
    
    //
    
    init() {
        do {
            let config = Realm.Configuration(fileURL: RealmManager.url, readOnly: false)
            self.realm = try Realm(configuration: config)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    //
    
    private func write(_ new: ImageInfo) {
        guard let realm = self.realm else { return }
        var removed = false
        
        realm.objects(ImageInfo.self).forEach { foo in
            if foo == new {
                do {
                    try realm.write {
                        realm.delete(foo)
                        removed = true
                    }
                } catch {
                    fatalError(error.localizedDescription)
                }
                return
            }
        }
        
        if !removed {
            do {
                // Realm에서 deleted된 object는 다시 add가 안 되기 때문에, 새로 정의를 해줘야함
                // *** Terminating app due to uncaught exception 'RLMException', reason: 'Adding a deleted or invalidated object to a Realm is not permitted'
                let new = ImageInfo(display_sitename: new.display_sitename, doc_url: new.doc_url, thumbnail_url: new.thumbnail_url, image_url: new.image_url)
                try realm.write { realm.add(new) }
                return
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    enum RealmManagerError: Error {
        case FailedToFindDocumentDirectory
    }
}

extension RealmManager: FavortiesDelegate {
    func performFavoritesChange(_ new: ImageInfo) {
        self.write(new)
    }
}
