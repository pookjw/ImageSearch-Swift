//
//  ImageBaseViewController.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import Kingfisher

// ImageBaseViewController는 SearchViewController와 FavoritesViewController가 inherit하는 클래스 입니다.
// 두 View는 공통적으로 UICollectionView를 사용하기 때문에 서로 공유하는 method를 여기에 넣었습니다.

class ImageBaseViewController: UIViewController {

    var imageInfo: [ImageInfo] = []
    weak var cv: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension ImageBaseViewController: UICollectionViewDataSource {
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
        
        if FavoritesManager.shared.list.contains(i) {
            cell.starImage.image = UIImage(systemName: "star.fill")
            cell.favorited = true
        } else {
            cell.starImage.image = UIImage(systemName: "star")
            cell.favorited = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.cv?.cellForItem(at: indexPath) as? ImageBaseCollectionViewCell {
            self.performSegue(withIdentifier: "ShowDetail", sender: cell)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "ShowDetail":
            guard let cell = sender as? ImageBaseCollectionViewCell, let indexPath = cv?.indexPath(for: cell) else {
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

extension ImageBaseViewController: UICollectionViewDelegateFlowLayout {
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
