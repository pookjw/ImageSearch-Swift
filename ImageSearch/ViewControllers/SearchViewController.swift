//
//  SearchViewController.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import RealmSwift

// 검색하는 View 입니다.

class SearchViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    let searchViewModel: SearchViewModel = SearchViewModel()
    private var token: NotificationToken?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: MyActivityIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let results = RealmFavoritesManager.favorites
        token = results.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_): ()
            case .update(_, _, _, _):
                self?.collectionView.reloadData()
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "ShowDetail":
            guard let cell = sender as? ImageCollectionViewCell, let indexPath = collectionView?.indexPath(for: cell) else {
                fatalError("Unexpected cell.")
            }
            guard let destNC = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination.")
            }
            let destVC = destNC.topViewController as! DetailViewController
            destVC.detailModel.imageInfo = searchViewModel.imageInfo[indexPath.row]
        default:
            fatalError("Unexpected destination.")
        }
    }
    
    deinit {
        guard let token = token else { return }
        token.invalidate()
        if SettingsManager.show_deinit_log_message {
            print("deinit: SearchViewController")
        }
    }
    
    private func searchCompletion() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            self.activityIndicator.isHidden = true
            self.title = self.searchViewModel.searchText
            InfoView.showIn(viewController: self, message: "Success!")
        }
    }
    
    private func searchErrorHandler(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            InfoView.showIn(viewController: self, message: error.localizedDescription)
        }
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) { }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        activityIndicator.isHidden = false
        guard let text = searchBar.text else { return }
        searchViewModel.searchText = text
        searchViewModel.request(errorHandler: searchErrorHandler, completion: searchCompletion)
        searchController.isActive = false
    }
}


extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchViewModel.imageInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            fatalError("Failed to load ImageCollectionViewCell on SearchViewController")
        }
        
        let imageInfo = searchViewModel.imageInfo[indexPath.row]
        let rancom_color = UIColor.getRamdomColor()
        
        cell.imageInfo = imageInfo
        cell.thumbnailImage.kf.indicatorType = .activity
        cell.thumbnailImage.kf.setImage(with: URL(string: imageInfo.thumbnail_url), placeholder: nil)
        cell.siteName.text = imageInfo.display_sitename
        cell.layer.shadowColor = rancom_color.color.cgColor
        cell.siteName.textColor = rancom_color.inverted
        cell.layer.shadowOpacity = 1
        cell.layer.shadowOffset = .zero
        cell.layer.shadowRadius = 8
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 1
        cell.layer.borderColor = rancom_color.inverted.cgColor
        
        if RealmFavoritesManager.didFavorite(imageInfo) == nil {
            cell.starImage.image = UIImage(systemName: "star")
            cell.favorited = false
        } else {
            cell.starImage.image = UIImage(systemName: "star.fill")
            cell.favorited = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView?.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            performSegue(withIdentifier: "ShowDetail", sender: cell)
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let viewWidth = view.frame.width
        let itemsInRow: CGFloat = CGFloat(Int(viewWidth / 115))
        let spacing = (view.frame.width - 115 * itemsInRow) / (2 * itemsInRow)
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
}
