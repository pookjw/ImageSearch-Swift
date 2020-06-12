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
        super.cv = self.collectionView
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
        let showActivitorIndicator = UIAlertAction(title: "Show Activity Indicator", style: .default, handler: { _ in self.activityIndicator.isHidden = false })
        let randomizeAllCellColours = UIAlertAction(title: "Randomize All Colours", style: .default, handler: { _ in
            for idx in 0..<super.imageInfo.count {
                let indexPath = IndexPath(row: idx, section: 0)
                self.collectionView.cellForItem(at: indexPath)?.layer.shadowColor = getRamdomColor().color.cgColor
            }
        })
        
        let changeTimerMethod = UIAlertAction(title: "Change Timer Method", style: .default, handler: { _ in
             let controller = UIAlertController(title: "Select Method", message: nil, preferredStyle: .alert)
            
            let action_1 = UIAlertAction(title: "Method 1", style: .default, handler: { _ in
                InfoView.timer = .one
                InfoView.showIn(viewController: self, message: "This is Method 1.")
            })
            let action_2 = UIAlertAction(title: "Method 2", style: .default, handler: { _ in
                InfoView.timer = .two
                InfoView.showIn(viewController: self, message: "This is Method 2.")
            })
            let action_3 = UIAlertAction(title: "Method 3", style: .default, handler: { _ in
                InfoView.timer = .three
                InfoView.showIn(viewController: self, message: "This is Method 3.")
            })
            let action_4 = UIAlertAction(title: "Method 4", style: .default, handler: { _ in
                InfoView.timer = .three
                InfoView.showIn(viewController: self, message: "This is Method 4.")
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            for a in [action_1, action_2, action_3, action_4, cancelButton] {
                controller.addAction(a)
            }
            
            self.present(controller, animated: true, completion: nil)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        for a in [showInfoViewAction, showActivitorIndicator, randomizeAllCellColours, changeTimerMethod, (cancelButton)] {
            controller.addAction(a)
        }
        
        present(controller, animated: true, completion: nil)
    }
}

class MyActivityIndicator: UIActivityIndicatorView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isHidden = true
    }
}
