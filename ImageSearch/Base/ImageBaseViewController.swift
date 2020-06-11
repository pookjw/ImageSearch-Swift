//
//  ImageBaseViewController.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import Kingfisher

class ImageBaseViewController: UIViewController {

    var imageInfo: [ImageInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ImageBaseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageBaseCollectionViewCell", for: indexPath) as? ImageBaseCollectionViewCell else {
            fatalError("Failed to load ImageBaseCollectionViewCell on SearchViewController")
        }
        
        let i = self.imageInfo[indexPath.row]
        
        cell.thumbnailImage.kf.indicatorType = .activity
        cell.thumbnailImage.kf.setImage(with: URL(string: i.thumbnail_url), placeholder: nil)
        cell.siteName.text = i.display_sitename
        
        return cell
    }
    
    
}

extension ImageBaseViewController: UICollectionViewDelegate {
    
}

//
