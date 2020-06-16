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
    
    let searchController = UISearchController(searchResultsController: nil)
    private var FBM_delegate_idx: Int?
    
    //
    
    var current_page = 1
    var max_page = 1
    var search_text = ""
    var search_done = false
    var scroll_done = false
    
    //
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: MyActivityIndicator!
    @IBOutlet weak var bulbButton: UIBarButtonItem!
    
    @IBAction func bulbAction(_ sender: Any) {
        self.showActionSheet()
    }
    
    //
    
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
        self.current_page = 1
        self.max_page = 1
        self.doSearch(reset: true)
        self.searchController.isActive = false
    }
}

// 검색
extension SearchViewController {
    // 새로운 검색어가 들어오면 현재 collectionView를 reset 합니다 (reset = true). 만약 collectionView에 검색 결과를 추가하면서 next page를 불러오고 싶다면 reset을 false로 하면 됩니다.
    private func doSearch(reset: Bool) {
        guard self.max_page >= self.current_page else { return }
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
                        super.imageInfo = []
                    }
                    decoded.documents.forEach { foo in
                        let imageInfo = ImageInfo(display_sitename: foo.display_sitename, doc_url: foo.doc_url, thumbnail_url: foo.thumbnail_url, image_url: foo.image_url)
                        super.imageInfo.append(imageInfo)
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.max_page = decoded.meta.pageable_count
                    
                    self.collectionView.reloadData()
                    self.activityIndicator.isHidden = true
                    self.title = self.search_text
                    
                    self.search_done = true
                    self.scroll_done = false
                    
                    InfoView.showIn(viewController: self, message: "Success!")
                }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == super.imageInfo.count - 3 {
            if search_done && scroll_done {
                search_done = false
                scroll_done = false
                
                self.activityIndicator.isHidden = false
                self.current_page += 1
                self.doSearch(reset: false)
            } else {
                scroll_done = false
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scroll_done = decelerate
    }
}

// 새로운 Favorite이 들어오면 실행
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

