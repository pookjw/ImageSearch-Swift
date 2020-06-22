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
    
    //
    
    var current_page = 1
    var max_page = 1
    var search_text = ""
    var search_done = false
    var scroll_done = false
    var imageInfo: [ImageInfo] = []
    private var token: NotificationToken?
    
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
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.searchController = searchController
        
        let results = RealmFavoritesManager.favorites
        // MARK: Todo - invalidate on deinit
        self.token = results.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_): ()
            case .update(_, _, _, _):
                self?.collectionView.reloadData()
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func showActionSheet() {
        let controller = UIAlertController(title: "Select Action", message: nil, preferredStyle: .alert)
        
        let showInfoViewAction = UIAlertAction(title: "Show InfoView", style: .default, handler: { _ in InfoView.showIn(viewController: self, message: "Test")})
        let showActivitorIndicator = UIAlertAction(title: "Show Activity Indicator", style: .default, handler: { _ in self.activityIndicator.isHidden = false })
        let randomizeAllCellColours = UIAlertAction(title: "Randomize All Colours", style: .default, handler: { _ in
            for idx in 0..<self.imageInfo.count {
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
                        self.imageInfo = []
                    }
                    decoded.documents.forEach { foo in
                        let imageInfo = ImageInfo(display_sitename: foo.display_sitename, doc_url: foo.doc_url, thumbnail_url: foo.thumbnail_url, image_url: foo.image_url)
                        self.imageInfo.append(imageInfo)
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
        if indexPath.item == self.imageInfo.count - 3 {
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

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageBaseCollectionViewCell", for: indexPath) as? ImageBaseCollectionViewCell else {
            fatalError("Failed to load ImageBaseCollectionViewCell on SearchViewController")
        }
        
        let i = self.imageInfo[indexPath.row]
        cell.imageInfo = i
        
        cell.thumbnailImage.kf.indicatorType = .activity
        cell.thumbnailImage.kf.setImage(with: URL(string: i.thumbnail_url), placeholder: nil)
        //cell.contentView.backgroundColor = .red
        cell.siteName.text = i.display_sitename
        let rancom_color = UIColor.getRamdomColor()
        cell.layer.shadowColor = rancom_color.color.cgColor
        cell.siteName.textColor = rancom_color.inverted
        cell.layer.shadowOpacity = 1
        cell.layer.shadowOffset = .zero
        cell.layer.shadowRadius = 8
        
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 1
        cell.layer.borderColor = rancom_color.inverted.cgColor
        
        if RealmFavoritesManager.didFavorite(i) != nil {
            cell.starImage.image = UIImage(systemName: "star.fill")
            cell.favorited = true
        } else {
            cell.starImage.image = UIImage(systemName: "star")
            cell.favorited = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView?.cellForItem(at: indexPath) as? ImageBaseCollectionViewCell {
            self.performSegue(withIdentifier: "ShowDetail", sender: cell)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "ShowDetail":
            guard let cell = sender as? ImageBaseCollectionViewCell, let indexPath = self.collectionView?.indexPath(for: cell) else {
                fatalError("Unexpected cell.")
            }
            guard let destNC = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination.")
            }
            let destVC = destNC.topViewController as! DetailViewController
            
            destVC.imageInfo = self.imageInfo[indexPath.row]
        default:
            fatalError("Unexpected destination.")
        }
    }
    
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let viewWidth = view.frame.width
        let itemsInRow: CGFloat = CGFloat(Int(viewWidth / 115))
        var spacing = (view.frame.width - 115 * itemsInRow) / (2 * itemsInRow)

        if spacing < CGFloat(0) { // minimum spacing
            spacing = 0 // set to minumum spacing
        }
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
}


// 새로운 Favorite이 들어오면 실행
//extension SearchViewController: FavortiesDelegate {
//    func performFavoritesChange(_ new: ImageInfo) {
//        guard let cells = self.collectionView.visibleCells as? [ImageBaseCollectionViewCell] else {
//            return
//        }
//
//        cells.forEach { cell in
//            if cell.imageInfo == new {
//                cell.favorited.toggle()
//                if cell.favorited {
//                    cell.starImage.image = UIImage(systemName: "star.fill")
//                } else {
//                    cell.starImage.image = UIImage(systemName: "star")
//                }
//                return
//            }
//        }
//    }
//}
