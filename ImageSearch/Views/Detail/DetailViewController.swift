//
//  DetailViewController.swift
//  ImageSearch
//
//  Created by pook on 6/12/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import Kingfisher
import Photos

class DetailViewController: UIViewController {
    
    var imageInfo: ImageInfo!
    
    @IBOutlet weak var largeImage: UIImageView!
    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
    @IBAction func saveButton(_ sender: Any) {
        do {
            guard let url = URL(string: imageInfo.image_url) else {
                throw ImageError.FailedToParseURL
            }
            let data = try Data(contentsOf: url)
            
            guard let image = UIImage(data: data) else {
                throw ImageError.FailedToParseImage
            }
            let photos = PHPhotoLibrary.authorizationStatus()
            if photos == .notDetermined {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized{
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savedView(_:didFinishSavingWithError:contextInfo:)), nil)
                    } else {
                        InfoView.showIn(viewController: self, message: "Authorization failed")
                    }
                })
            } else {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savedView(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        } catch {
            print(error.localizedDescription)
            InfoView.showIn(viewController: self, message: error.localizedDescription)
        }
    }
    
    @IBAction func starBtn(_ sender: Any) {
        FavoritesManager.update(self.imageInfo)
        if FavoritesManager.list.contains(imageInfo) {
            InfoView.showIn(viewController: self, message: "Favorited!")
        } else {
            InfoView.showIn(viewController: self, message: "Removed!")
        }
    }
    @IBOutlet weak var starBarBtn: UIBarButtonItem!
    
    @IBAction func safariBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowWeb", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = imageInfo.display_sitename
        self.largeImage.kf.indicatorType = .activity
        self.largeImage.kf.setImage(with: URL(string: imageInfo.image_url))
        
        FavoritesManager.delegates.append(self)
        self.performFavoritesChange(self.imageInfo)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "ShowWeb":
            guard let destVC = segue.destination as? WebViewController else {
                fatalError("Unexpected destination.")
            }
            
            destVC.url = URL(string: self.imageInfo.doc_url)
        default:
            fatalError("Unexpected destination.")
        }
    }
   
    @objc private func savedView(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            InfoView.showIn(viewController: self, message: error.localizedDescription)
        } else {
            print("Saved!")
            InfoView.showIn(viewController: self, message: "Saved!")
        }
    }
    
    private enum ImageError: Error {
        case FailedToParseURL, FailedToParseImage
    }
}

extension DetailViewController: FavortiesDelegate {
    func performFavoritesChange(_ new: ImageInfo) {
        if FavoritesManager.list.contains(new) {
            self.starBarBtn.image = UIImage(systemName: "star.fill")
        } else {
            self.starBarBtn.image = UIImage(systemName: "star")
        }
    }
}
