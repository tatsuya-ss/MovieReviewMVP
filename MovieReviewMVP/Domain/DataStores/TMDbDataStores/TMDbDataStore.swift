//
//  TMDbDataStore.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/07.
//

import Foundation

enum TMDbSearchError: Error {
    case urlError
    case requestError
    case responseError
}

typealias ResultHandler<T> = (Result<T, Error>) -> Void

protocol TMDbDataStoreProtocol {
    func fetchVideoWorks(fetchState: FetchMovieState, query: String,
                    completion: @escaping ResultHandler<TMDbSearchResponses>)
}

final class TMDbDataStore: TMDbDataStoreProtocol {

    func fetchVideoWorks(fetchState: FetchMovieState, query: String,
                    completion: @escaping ResultHandler<TMDbSearchResponses>) {
        guard let url = TMDbAPI.SearchRequest(query: query,
                                              page: "1").returnSearchURL()
        else {
            completion(.failure(TMDbSearchError.urlError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            do {
                if let error = error {
                    completion(.failure(TMDbSearchError.requestError))
                    print(error)
                }
                guard let data = data,
                      let response = response as? HTTPURLResponse else {
                          completion(.failure(TMDbSearchError.responseError))
                          return
                      }
                
                if response.statusCode == 200 {
                    let data = try JSONDecoder().decode(TMDbSearchResponses.self,
                                                        from: data)
                    completion(.success(data))
                }
            } catch {
                completion(.failure(TMDbSearchError.responseError))
                print(error)
            }
        }
        task.resume()
    }
    
}
