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

final class DetailViewController: UIViewController {
    let detailModel: DetailModel = DetailModel()
    
    @IBOutlet weak var largeImage: UIImageView!
    @IBOutlet weak var starBarBtn: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: MyActivityIndicator!
    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: {})
    }
    @IBAction func saveButton(_ sender: Any) {
        activityIndicator.isHidden = false
        detailModel.savePhoto(self)
    }
    @IBAction func starBtn(_ sender: Any) {
        RealmFavoritesManager.update(detailModel.imageInfo)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func safariBtn(_ sender: Any) {
        performSegue(withIdentifier: "ShowWeb", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = detailModel.imageInfo.display_sitename
        largeImage.kf.indicatorType = .activity
        largeImage.kf.setImage(with: URL(string: detailModel.imageInfo.image_url))
        
        if RealmFavoritesManager.didFavorite(detailModel.imageInfo) != nil {
            starBarBtn.image = UIImage(systemName: "star.fill")
        } else {
            starBarBtn.image = UIImage(systemName: "star")
        }
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
            
            destVC.url = URL(string: detailModel.imageInfo.doc_url)
        default:
            fatalError("Unexpected destination.")
        }
    }
}

extension DetailViewController: DetailModelProtocol {
    func savedPhotoCompletion(_ error: Error? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let error = error {
                InfoView.showIn(viewController: self, message: error.localizedDescription)
            } else {
                InfoView.showIn(viewController: self, message: "Saved!")
            }
            self.activityIndicator.isHidden = true
        }
    }
    
    @objc func savedPhotoCompletion(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        savedPhotoCompletion(error)
    }
}
