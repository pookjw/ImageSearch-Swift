//
//  FavoirtesViewController.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

class FavoirtesViewController: ImageBaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.cv = self.collectionView
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        super.imageInfo = ImageInfo.getSampleImageInfo()
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

