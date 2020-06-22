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

// SearchViewController와 FavoritesViewController에서 cell를 눌렀을 때 나오는 View 입니다.
// 사진을 크게 볼 수 있고, Favorite 지정, 사진 저장, 문서를 WebViewController로 열여주는 역할을 합니다.

class DetailViewController: UIViewController {
    
    var imageInfo: ImageInfo!
    private var FBM_delegate_idx: Int?
    private enum ImageError: Error {
        case FailedToParseURL, FailedToParseImage
    }
    
    //
    
    @IBOutlet weak var largeImage: UIImageView!
    
    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func saveButton(_ sender: Any) {
        self.activityIndicator.isHidden = false
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            do {
                guard let url = URL(string: self.imageInfo.image_url) else {
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
                            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savedPhotoCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
                        } else {
                            InfoView.showIn(viewController: self, message: "Authorization failed")
                        }
                    })
                } else {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savedPhotoCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            } catch {
                print(error.localizedDescription)
                InfoView.showIn(viewController: self, message: error.localizedDescription)
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    @IBAction func starBtn(_ sender: Any) {
        RealmFavoritesManager.update(self.imageInfo)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var starBarBtn: UIBarButtonItem!
    
    @IBAction func safariBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowWeb", sender: self)
    }
    
    @IBOutlet weak var activityIndicator: MyActivityIndicator!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = imageInfo.display_sitename
        self.largeImage.kf.indicatorType = .activity
        self.largeImage.kf.setImage(with: URL(string: imageInfo.image_url))
//        self.performFavoritesChange(self.imageInfo)
        
        if RealmFavoritesManager.didFavorite(self.imageInfo) != nil {
            self.starBarBtn.image = UIImage(systemName: "star.fill")
        } else {
            self.starBarBtn.image = UIImage(systemName: "star")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    deinit {
        if SettingsManager.show_deinit_log_message {
            print("deinit: DetailViewController")
        }
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
    
    //
   
    @objc private func savedPhotoCompletion(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            InfoView.showIn(viewController: self, message: error.localizedDescription)
        } else {
            print("Saved!")
            InfoView.showIn(viewController: self, message: "Saved!")
        }
    }
}

//// 새로운 Favorite이 들어오면 실행
//extension DetailViewController: FavortiesDelegate {
//    func performFavoritesChange(_ new: ImageInfo) {
//        if FavoritesManager.shared.list.contains(new) {
//            self.starBarBtn.image = UIImage(systemName: "star.fill")
//        } else {
//            self.starBarBtn.image = UIImage(systemName: "star")
//        }
//    }
//}
