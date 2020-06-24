//
//  ImageCollectionViewCell.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var siteName: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    var imageInfo: ImageInfo?
}
