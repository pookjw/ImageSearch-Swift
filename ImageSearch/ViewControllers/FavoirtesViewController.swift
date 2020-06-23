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

final class FavoirtesViewController: UIViewController {
    private var token: NotificationToken?
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
        
        let results = RealmFavoritesManager.favorites
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
            
            destVC.detailModel.imageInfo = RealmFavoritesManager.favorites[indexPath.row]
        default:
            fatalError("Unexpected destination.")
        }
    }
    
    deinit {
        guard let token = token else { return }
        token.invalidate()
        if SettingsManager.show_deinit_log_message {
            print("deinit: FavoirtesViewController")
        }
    }
}

extension FavoirtesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RealmFavoritesManager.favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            fatalError("Failed to load ImageCollectionViewCell on SearchViewController")
        }
        
        let imageInfo = RealmFavoritesManager.favorites[indexPath.row]
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

extension FavoirtesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let viewWidth = view.frame.width
        let itemsInRow: CGFloat = CGFloat(Int(viewWidth / 115))
        let spacing = (view.frame.width - 115 * itemsInRow) / (2 * itemsInRow)
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
}
