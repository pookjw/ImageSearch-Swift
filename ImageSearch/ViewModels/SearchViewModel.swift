//
//  SearchViewModel.swift
//  ImageSearch
//
//  Created by pook on 6/22/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation
import RxSwift

final class SearchViewModel {
    //    var imageInfo: [ImageInfo] = []
    var imageInfo: BehaviorSubject<[ImageInfo]> = BehaviorSubject(value: [])
    private var searchResult: PublishSubject<SearchResult> = PublishSubject()
    private var currentPage: Int?
    private var maxPage: Int?
    var searchText: BehaviorSubject<String> = BehaviorSubject(value: "")
    private let searchModel: SearchModel
    private let disposeBag: DisposeBag = DisposeBag()
    private var allowReset: Bool = false
    
    init() {
        searchModel = SearchModel()
        
        searchText
            .subscribe(onNext: { [weak self] text in
                guard text != "" else { return }
                guard let self = self else { return }
                self.allowReset = true
                self.currentPage = 1
                self.searchModel.request(text: text,
                                         page: 1, observable: self.searchResult)
            })
            .disposed(by: disposeBag)
        
        searchResult
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.maxPage = value.meta.pageable_count
                
                var temp: [ImageInfo] = []
                value.documents.forEach {
                    let imageInfo = ImageInfo(display_sitename: $0.display_sitename, doc_url: $0.doc_url, thumbnail_url: $0.thumbnail_url, image_url: $0.image_url)
                    temp.append(imageInfo)
                }
                do {
                    if self.allowReset {
                        self.imageInfo.onNext(temp)
                        self.allowReset = false
                    } else {
                        self.imageInfo.onNext(try self.imageInfo.value() + temp)
                    }
                } catch {
                    fatalError(error.localizedDescription)
                }
                },
                       onError: { [weak self] error in
                        guard let self = self else { return }
                        self.imageInfo.onError(error)
            })
            .disposed(by: disposeBag)
    }
    
    func loadNextPage() {
        allowReset = false
        guard let maxPage = maxPage else { return }
        guard let currentPage = currentPage else { return }
        guard maxPage > currentPage else { return }
        self.currentPage! += 1
        var text: String = ""
        
        do {
            text = try searchText.value()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        searchModel.request(text: text, page: currentPage+1, observable: searchResult)
    }
}
