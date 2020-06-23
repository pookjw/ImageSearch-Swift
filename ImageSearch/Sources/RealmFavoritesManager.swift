//
//  RealmFavoritesManager.swift
//  ImageSearch
//
//  Created by pook on 6/15/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmFavoritesManager {
    
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
    
    static var config: Realm.Configuration = Realm.Configuration(fileURL: RealmFavoritesManager.url, schemaVersion: 0, objectTypes: [ImageInfo.self])
    
    static var favorites: Results<ImageInfo> = {
        do {
            let realm: Realm = try Realm(configuration: RealmFavoritesManager.config)
            return realm.objects(ImageInfo.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    private enum RealmManagerError: Error {
        case FailedToFindDocumentDirectory
    }
    
    static func update(_ imageInfo: ImageInfo) {
        do {
            let imageInfo = imageInfo.newRef()
            let realm: Realm = try Realm(configuration: RealmFavoritesManager.config)
            try realm.write() {
                if let object = didFavorite(imageInfo) {
                    realm.delete(object)
                } else {
                    realm.add(imageInfo)
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func didFavorite(_ imageInfo: ImageInfo) -> ImageInfo? {
        for object in RealmFavoritesManager.favorites {
            if object == imageInfo {
                return object
            }
        }
        return nil
    }
}

