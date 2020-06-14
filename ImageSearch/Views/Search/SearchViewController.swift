//
//  SearchViewController.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

// 검색하는 View 입니다.

class SearchViewController: ImageBaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: MyActivityIndicator!
    @IBOutlet weak var bulbButton: UIBarButtonItem!
    let searchController = UISearchController(searchResultsController: nil)
    private var FBM_delegate_idx: Int?
    
    //
    var current_page = 1
    var max_page = 1
    var search_text = ""
    //
    
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
        FBM_delegate_idx = FavoritesManager.shared.delegates.count
        FavoritesManager.shared.delegates.append(self)
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
    
    // 새로운 검색어가 들어오면 현재 collectionView를 reset 합니다. 만약 next page를 불러오고 싶다면 reset을 안하면 됩니다.
    // show_success는 InfoView로 Success!를 보여줄지 말지 입니다.
    private func doSearch(reset: Bool, show_success: Bool) {
        guard self.max_page >= self.current_page else { return }
        if reset {
            self.current_page = 1
            self.max_page = 1
        }
        
        SearchManaer.shared.request(
            text: self.search_text,
            page: self.current_page,
            errorHandler: { (error) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    InfoView.showIn(viewController: self, message: error.localizedDescription)
                }
        },
            completion: { (decoded) in
                DispatchQueue.main.async { //[weak super] in
                    if reset {
                        super.imageInfo = decoded.documents
                    } else {
                        super.imageInfo.append(contentsOf: decoded.documents)
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.max_page = decoded.meta.pageable_count
                    self.collectionView.reloadData()
                    self.activityIndicator.isHidden = true
                    self.title = self.search_text
                    if show_success { InfoView.showIn(viewController: self, message: "Success!") }
                }
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = 10.0 as CGFloat
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        if (maximumOffset - contentOffset <= threshold) && (maximumOffset - contentOffset != -5.0) && self.search_text != "" {
            self.current_page += 1
            self.doSearch(reset: false, show_success: false)
        }
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
        self.search_text = text
        self.doSearch(reset: true, show_success: true)
        self.searchController.isActive = false
    }
}

extension SearchViewController: FavortiesDelegate {
    func performFavoritesChange(_ new: ImageInfo) {
        guard let cells = self.collectionView.visibleCells as? [ImageBaseCollectionViewCell] else {
            return
        }
        
        cells.forEach { cell in
            if cell.imageInfo == new {
                cell.favorited.toggle()
                if cell.favorited {
                    cell.starImage.image = UIImage(systemName: "star.fill")
                } else {
                    cell.starImage.image = UIImage(systemName: "star")
                }
                return
            }
        }
    }
}

