//
//  SearchManager.swift
//  ImageSearch
//
//  Created by pook on 6/13/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation

typealias SearchResult = SearchManaer.SearchResult
typealias SearchError = SearchManaer.SearchError

class SearchManaer {
    let API = "https://dapi.kakao.com/v2/search/image"
    let KakaoAK = "dff576e28ce434796a2329a6a2366d76"
    
    static let shared = SearchManaer()
    
    struct SearchResult: Decodable {
        let meta: Meta
        let documents: [ImageInfo]
        
        struct Meta: Decodable {
            let pageable_count: Int
        }
    }
    
    static let emptyResult = SearchResult(meta: SearchResult.Meta.init(pageable_count: 1), documents: [])
    
    enum SearchError: Error {
        case invalidURL
        case invalidHTTPResponse
        case httpResponse(Int)
        case invalidData
    }
    
    func request(text: String, page: Int, errorHandler: @escaping ((Error) -> ()), completion: @escaping ((SearchResult) -> ())) {
        guard let url = URL(string: self.API), var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            errorHandler(SearchError.invalidURL)
            return
        }
        
        components.queryItems = [
            URLQueryItem(name: "query", value: text),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let finalURL = components.url else {
            errorHandler(SearchError.invalidURL)
            return
        }
        
        var request = URLRequest(url: finalURL)
//        request.allHTTPHeaderFields = [
//            "Authorization": "KakaoAK \(KakaoAK)"
//        ]
        request.setValue("KakaoAK \(KakaoAK)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                errorHandler(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorHandler(SearchError.invalidHTTPResponse)
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                errorHandler(SearchError.httpResponse(httpResponse.statusCode))
                return
            }
            
            guard let data = data else {
                errorHandler(SearchError.invalidData)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let decoded = try decoder.decode(SearchResult.self, from: data)
                //Thread.sleep(forTimeInterval: 3.0)
                completion(decoded)
            } catch {
                errorHandler(error)
            }
        }
        
        task.resume()
    }
}

