//
//  DetailModel.swift
//  ImageSearch
//
//  Created by pook on 6/23/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import Photos
import Alamofire

final class DetailModel {
    var imageInfo: ImageInfo!
    
    func savePhoto(_ sender: DetailModelProtocol) {
        guard let url = URL(string: imageInfo.image_url) else {
            sender.savedPhotoCompletion(ImageError.FailedToParseURL)
            return
        }
        AF.request(url).responseData(queue: DispatchQueue.global()) { response in
            switch response.result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    sender.savedPhotoCompletion(ImageError.FailedToParseImage)
                    return
                }
                
                let photos = PHPhotoLibrary.authorizationStatus()
                if photos == .notDetermined {
                    PHPhotoLibrary.requestAuthorization { status in
                        if status == .authorized{
                            UIImageWriteToSavedPhotosAlbum(image, sender, #selector(sender.savedPhotoCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
                        } else {
                            sender.savedPhotoCompletion(ImageError.FailedToSaveImage)
                        }
                    }
                } else {
                    UIImageWriteToSavedPhotosAlbum(image, sender, #selector(sender.savedPhotoCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            case .failure(let error):
                sender.savedPhotoCompletion(error)
            }
        }
    }
    
    private enum ImageError: Error {
        case FailedToParseURL, FailedToParseImage, FailedToSaveImage
    }
}

@objc protocol DetailModelProtocol {
    func savedPhotoCompletion(_ error: Error?)
    @objc func savedPhotoCompletion(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer)
}
