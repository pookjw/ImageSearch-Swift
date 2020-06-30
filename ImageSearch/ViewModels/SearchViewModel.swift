//
//  SearchViewModel.swift
//  ImageSearch
//
//  Created by pook on 6/22/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation

final class SearchViewModel {
    var imageInfo: [ImageInfo] = []
    private var currentPage: Int?
    private var maxPage: Int?
    var searchText: String? {
        didSet {
            currentPage = nil
            maxPage = nil
        }
    }
    private let searchModel: SearchModel
    
    init() {
        searchModel = SearchModel()
    }
    
    func request(errorHandler: @escaping ((Error) -> ()), completion: @escaping (() -> ())) {
        guard let searchText = searchText else {
            return
        }
        
        if currentPage == nil {
            currentPage = 1
        } else {
            currentPage! += 1
        }
        
        if maxPage != nil {
            guard currentPage! > maxPage! else { return }
        }
        
        searchModel.request(text: searchText,
                            page: currentPage!,
                            errorHandler: errorHandler,
                            completion: { [weak self] (decoded) in
                                if self?.currentPage == 1 {
                                    self?.imageInfo = []
                                }
                                self?.searchCompletion(decoded)
                                self?.maxPage = decoded.meta.pageable_count
                                completion()
        })
    }
    
    private func searchCompletion(_ decoded: SearchResult) {
        decoded.documents.forEach {
            let imageInfo = ImageInfo(display_sitename: $0.display_sitename, doc_url: $0.doc_url, thumbnail_url: $0.thumbnail_url, image_url: $0.image_url)
            self.imageInfo.append(imageInfo)
        }
    }
}
