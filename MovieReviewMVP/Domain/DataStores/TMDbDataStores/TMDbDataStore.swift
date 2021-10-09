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
    func fetchVideoWorks(page: Int, query: String,
                    completion: @escaping ResultHandler<TMDbSearchResponses>)
    func fetchUpcomingVideoWorks(completion: @escaping ResultHandler<TMDbSearchResponses>)
    func fetchVideoWorkDetail(videoWork: VideoWork,
                              completion: @escaping ResultHandler<TMDbCredits>)
}

final class TMDbDataStore: TMDbDataStoreProtocol {

    func fetchVideoWorks(page: Int, query: String,
                    completion: @escaping ResultHandler<TMDbSearchResponses>) {
        guard let url = TMDbAPI.SearchRequest(query: query,
                                              page: page).returnSearchURL()
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
    
    func fetchVideoWorkDetail(videoWork: VideoWork,
                              completion: @escaping ResultHandler<TMDbCredits>) {
        guard let url = TMDbAPI.DetailsRequest(id: videoWork.id, mediaType: videoWork.mediaType ?? "movie").returnDetailsURLRequest() else {
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
                    let data = try JSONDecoder().decode(TMDbCredits.self, from: data)
                    completion(.success(data))
                }
            } catch {
                completion(.failure(TMDbSearchError.responseError))
                print(error)
            }
        }
        task.resume()
    }

    func fetchUpcomingVideoWorks(completion: @escaping ResultHandler<TMDbSearchResponses>) {
        guard let url = TMDbAPI.UpcomingRequest().upcomingURL
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
