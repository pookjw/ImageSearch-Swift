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
    
    init() {
        do {
            let config = Realm.Configuration(fileURL: RealmManager.url, readOnly: false)
            self.realm = try Realm(configuration: config)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func write(_ new: ImageInfoObject) {
        guard let realm = self.realm else { return }
        var removed = false
        
        realm.objects(ImageInfoObject.self).forEach { foo in
            if self.isEqual(foo, new) {
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
                try realm.write { realm.add(new) }
                return
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func isEqual(_ left: ImageInfoObject, _ right: ImageInfoObject) -> Bool {
        return left.display_sitename == right.display_sitename && left.doc_url == right.doc_url && left.thumbnail_url == right.thumbnail_url && left.image_url == right.image_url
    }
    
    enum RealmManagerError: Error {
        case FailedToFindDocumentDirectory
    }
}

class ImageInfoObject: Object {
    @objc dynamic var display_sitename: String
    @objc dynamic var doc_url: String
    @objc dynamic var thumbnail_url: String
    @objc dynamic var image_url: String
    
    init(_ imageInfo: ImageInfo) {
        self.display_sitename = imageInfo.display_sitename
        self.doc_url = imageInfo.doc_url
        self.thumbnail_url = imageInfo.thumbnail_url
        self.image_url = imageInfo.image_url
    }
    
    required init() {
        self.display_sitename = ""
        self.doc_url = ""
        self.thumbnail_url = ""
        self.image_url = ""
    }
}

extension RealmManager: FavortiesDelegate {
    func performFavoritesChange(_ new: ImageInfo) {
        let obj = ImageInfoObject(new)
        self.write(obj)
    }
}
