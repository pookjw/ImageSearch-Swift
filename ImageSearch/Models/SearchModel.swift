//
//  SearchModel.swift
//  ImageSearch
//
//  Created by pook on 6/22/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation
import Alamofire

struct SearchResult: Decodable {
    let meta: Meta
    let documents: [Documents]
}

struct Meta: Decodable {
    let pageable_count: Int
}

struct Documents: Decodable {
    var display_sitename: String
    var doc_url: String
    var thumbnail_url: String
    var image_url: String
}

final class SearchModel {
    private let API = "https://dapi.kakao.com/v2/search/image"
    private let KakaoAK = "dff576e28ce434796a2329a6a2366d76"
    
    enum SearchError: Error {
        case invalidURL
        case invalidHTTPResponse
        case httpResponse(Int)
        case invalidData
    }
    
    enum NetworkType: Int, CaseIterable {
        case urlsession = 0, alamofire
    }
    
    func request(text: String, page: Int, errorHandler: @escaping ((Error) -> ()), completion: @escaping ((SearchResult) -> ())) {
        switch SettingsManager.nekwork_type {
        case .urlsession:
            guard let url = URL(string: API), var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
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
                
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode(SearchResult.self, from: data)
                    completion(decoded)
                } catch {
                    errorHandler(error)
                }
            }
            
            task.resume()
        case .alamofire:
            let parameters = ["query": text, "page": String(page)]
            let headers: HTTPHeaders = [
                "Authorization": "KakaoAK \(KakaoAK)"
            ]
            
            AF.request(API, method: .get, parameters: parameters, headers: headers, requestModifier: { $0.timeoutInterval = 10 })
                .validate(statusCode: 200...299)
                .responseJSON(queue: DispatchQueue.global(), completionHandler: { response in
                    switch response.result {
                    case .success:
                        do {
                            guard let data = response.data else { throw SearchError.invalidData }
                            let decoder = JSONDecoder()
                            let decoded = try decoder.decode(SearchResult.self, from: data)
                            completion(decoded)
                        } catch {
                            errorHandler(error)
                        }
                    case let .failure(error):
                        errorHandler(error)
                    }
                })
        }
    }
}
