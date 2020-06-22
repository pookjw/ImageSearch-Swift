//
//  FavoirtesViewController.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import RealmSwift

// Favorite된 사진들을 모아보는 View 입니다.

class FavoirtesViewController: UIViewController {
    
    private var FBM_delegate_idx: Int?
    private var token: NotificationToken?
    
    //

    @IBOutlet weak var collectionView: UICollectionView!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
        
        let results = RealmFavoritesManager.favorites
        // MARK: Todo - invalidate on deinit
        token = results.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                self?.collectionView.reloadData()
            case .update(_, _, _, _):
                self?.collectionView.reloadData()
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

extension FavoirtesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RealmFavoritesManager.favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageBaseCollectionViewCell", for: indexPath) as? ImageBaseCollectionViewCell else {
            fatalError("Failed to load ImageBaseCollectionViewCell on SearchViewController")
        }
        
        let imageInfo = RealmFavoritesManager.favorites[indexPath.row]
        cell.imageInfo = imageInfo
        
        cell.thumbnailImage.kf.indicatorType = .activity
        cell.thumbnailImage.kf.setImage(with: URL(string: imageInfo.thumbnail_url), placeholder: nil)
        //cell.contentView.backgroundColor = .red
        cell.siteName.text = imageInfo.display_sitename
        let rancom_color = UIColor.getRamdomColor()
        cell.layer.shadowColor = rancom_color.color.cgColor
        cell.siteName.textColor = rancom_color.inverted
        cell.layer.shadowOpacity = 1
        cell.layer.shadowOffset = .zero
        cell.layer.shadowRadius = 8
        
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 1
        cell.layer.borderColor = rancom_color.inverted.cgColor
        
        if RealmFavoritesManager.didFavorite(imageInfo) != nil {
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
            guard let cell = sender as? ImageBaseCollectionViewCell, let indexPath = collectionView?.indexPath(for: cell) else {
                fatalError("Unexpected cell.")
            }
            guard let destNC = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination.")
            }
            let destVC = destNC.topViewController as! DetailViewController
            
            destVC.imageInfo = RealmFavoritesManager.favorites[indexPath.row]
        default:
            fatalError("Unexpected destination.")
        }
    }
    
}

extension FavoirtesViewController: UICollectionViewDelegateFlowLayout {
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
