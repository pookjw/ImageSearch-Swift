//
//  SearchViewController.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

// 검색하는 View 입니다.

final class SearchViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let searchViewModel: SearchViewModel = SearchViewModel()
    private var token: NotificationToken?
    private let disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: MyActivityIndicator!
    weak var footerView: SearchFooterCollectionReusableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchViewModel.imageInfo
            .subscribe(onNext: { [weak self] value in
                guard value != [] else {
                    return
                }
                self?.searchCompletion()
                },
                       onError: { [weak self] error in self?.searchErrorHandler(error) })
            .disposed(by: disposeBag)
        
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
            //            destVC.detailModel.imageInfo = searchViewModel.imageInfo[indexPath.row]
            do {
                destVC.detailModel.imageInfo = try searchViewModel.imageInfo.value()[indexPath.row]
            } catch {
                fatalError(error.localizedDescription)
            }
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
            self.footerView?.loadNextPageButton.isHidden = false
            //            self.title = self.searchViewModel.searchText
            InfoView.showIn(viewController: self, message: "Success!")
        }
    }
    
    private func searchErrorHandler(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            InfoView.showIn(viewController: self, message: error.localizedDescription)
        }
    }
    
    @objc
    private func loadNextPage(sender: Any) {
        searchViewModel.loadNextPage()
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) { }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        activityIndicator.isHidden = false
        guard let text = searchBar.text else { return }
        searchViewModel.searchText.onNext(text)
        searchController.isActive = false
    }
}


extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        do {
            return try searchViewModel.imageInfo.value().count
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            fatalError("Failed to load ImageCollectionViewCell on SearchViewController")
        }
        do {
            let imageInfo: ImageInfo = try searchViewModel.imageInfo.value()[indexPath.row]
            cell.configure(imageInfo)
        } catch {
            fatalError(error.localizedDescription)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView?.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            performSegue(withIdentifier: "ShowDetail", sender: cell)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchFooterCollectionReusableView", for: indexPath) as! SearchFooterCollectionReusableView
        footerView = footer
        footer.isHidden = false
        footer.loadNextPageButton.addTarget(self, action: #selector(loadNextPage(sender:)), for: .touchUpInside)
        return footer
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
