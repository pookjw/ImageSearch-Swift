//
//  ImageCollectionViewCell.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import Kingfisher

final class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var siteName: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    var imageInfo: ImageInfo?
    
    func configure(_ imageInfo: ImageInfo) {
        self.imageInfo = imageInfo
        let random_color = UIColor.getRamdomColor()
        
        self.thumbnailImage.kf.indicatorType = .activity
        self.thumbnailImage.kf.setImage(with: URL(string: imageInfo.thumbnail_url), placeholder: nil)
        self.siteName.text = imageInfo.display_sitename
        self.layer.shadowColor = random_color.color.cgColor
        self.siteName.textColor = random_color.inverted
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 8
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1
        self.layer.borderColor = random_color.inverted.cgColor
        
        if RealmFavoritesManager.didFavorite(imageInfo) == nil {
            self.starImage.image = UIImage(systemName: "star")
        } else {
            self.starImage.image = UIImage(systemName: "star.fill")
        }
    }
}
