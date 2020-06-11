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
    @IBOutlet weak var activityIndicator: MyActivityIndicator!
    @IBOutlet weak var bulbButton: UIBarButtonItem!
    
    @IBAction func bulbAction(_ sender: Any) {
        self.showActionSheet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        super.imageInfo = ImageInfo.getSampleImageInfo()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        InfoView.showIn(viewController: self, message: "Welcome!")
    }
    
    private func showActionSheet() {
        let controller = UIAlertController(title: "Select Action", message: nil, preferredStyle: .alert)
        
        let showInfoViewAction = UIAlertAction(title: "Show InfoView", style: .default, handler: { _ in InfoView.showIn(viewController: self, message: "Test")})
        let showAI = UIAlertAction(title: "Show AI", style: .default, handler: { _ in self.activityIndicator.isHidden = false })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        controller.addAction(showInfoViewAction)
        controller.addAction(showAI)
        controller.addAction(cancelButton)
        
        present(controller, animated: true, completion: nil)
    }
}

class MyActivityIndicator: UIActivityIndicatorView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isHidden = true
    }
}
