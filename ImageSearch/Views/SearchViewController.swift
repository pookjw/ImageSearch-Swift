//
//  SearchViewController.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

class SearchViewController: ImageBaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        super.imageInfo = ImageInfo.getSampleImageInfo()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        InfoView.showIn(viewController: self, message: "Test")
    }
}
