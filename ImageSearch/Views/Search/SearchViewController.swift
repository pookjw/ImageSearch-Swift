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
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBAction func bulbAction(_ sender: Any) {
        self.showActionSheet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.cv = self.collectionView
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }
    
    private func showActionSheet() {
        let controller = UIAlertController(title: "Select Action", message: nil, preferredStyle: .alert)
        
        let showInfoViewAction = UIAlertAction(title: "Show InfoView", style: .default, handler: { _ in InfoView.showIn(viewController: self, message: "Test")})
        let showActivitorIndicator = UIAlertAction(title: "Show Activity Indicator", style: .default, handler: { _ in self.activityIndicator.isHidden = false })
        let randomizeAllCellColours = UIAlertAction(title: "Randomize All Colours", style: .default, handler: { _ in
            for idx in 0..<super.imageInfo.count {
                let indexPath = IndexPath(row: idx, section: 0)
                self.collectionView.cellForItem(at: indexPath)?.layer.shadowColor = UIColor.getRamdomColor().color.cgColor
            }
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        for a in [showInfoViewAction, showActivitorIndicator, randomizeAllCellColours, cancelButton] {
            controller.addAction(a)
        }
        
        present(controller, animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) { }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.activityIndicator.isHidden = false
        guard let text = searchBar.text else { return }
        SearchManaer.shared.request(
            text: text,
            page: 1,
            errorHandler: { (error) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    InfoView.showIn(viewController: self, message: error.localizedDescription)
                }
        },
            completion: { (decoded) in
                DispatchQueue.main.async { //[weak super] in
                    super.imageInfo = decoded.documents
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.collectionView.reloadData()
                    self.activityIndicator.isHidden = true
                    InfoView.showIn(viewController: self, message: "Success!")
                }
        })
        
        self.searchController.isActive = false
    }
}
