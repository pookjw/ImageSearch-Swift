//
//  FavoirtesViewController.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

// Favorite된 사진들을 모아보는 View 입니다.

class FavoirtesViewController: ImageBaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var FBM_delegate_idx: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.cv = self.collectionView
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        FBM_delegate_idx = FavoritesManager.shared.delegates.count
        FavoritesManager.shared.delegates.append(self)
        super.imageInfo = FavoritesManager.shared.list
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension FavoirtesViewController: FavortiesDelegate {
    func performFavoritesChange(_ new: ImageInfo) {
        super.imageInfo = FavoritesManager.shared.list
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}
