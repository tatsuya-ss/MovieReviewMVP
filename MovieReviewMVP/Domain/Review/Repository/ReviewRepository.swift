//
//  ReviewRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/12.
//

import Foundation
import Firebase

protocol ReviewRepositoryProtocol {
    func checkSaved(movie: VideoWork,
                    completion: @escaping (Bool) -> Void)
    func save(movie: VideoWork, completion: @escaping (Result<(), Error>) -> Void)
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[VideoWork], Error>) -> Void)
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[VideoWork], Error>) -> Void)
    func delete(movie: VideoWork)
    func update(movie: VideoWork)
}

final class ReviewRepository: ReviewRepositoryProtocol {
    
    let dataStore: ReviewDataStoreProtocol!
    init(dataStore: ReviewDataStoreProtocol) {
        self.dataStore = dataStore
    }
    
    func checkSaved(movie: VideoWork,
                    completion: @escaping (Bool) -> Void) {
        dataStore.checkSaved(movie: movie, completion: completion)
    }
    
    func save(movie: VideoWork, completion: @escaping (Result<(), Error>) -> Void) {
        dataStore.save(movie: movie, completion: completion)
    }
    
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[VideoWork], Error>) -> Void) {
        dataStore.fetch(isStoredAsReview: isStoredAsReview,
                        sortState: sortState) { result in
            switch result {
            case .success(let data):
                let videoWorks = data.map { VideoWork(data: $0) }
                completion(.success(videoWorks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sort(isStoredAsReview: Bool,
              sortState: sortState,
              completion: @escaping (Result<[VideoWork], Error>) -> Void) {
        dataStore.sort(isStoredAsReview: isStoredAsReview,
                       sortState: sortState) { result in
            switch result {
            case .success(let data):
                let videoWorks = data.map { VideoWork(data: $0) }
                completion(.success(videoWorks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func delete(movie: VideoWork) {
        dataStore.delete(movie: movie)
    }
    
    func update(movie: VideoWork) {
        dataStore.update(movie: movie)
    }
    
}

private extension VideoWork {
    init(data: [String: Any]) {
        let timestamp = data["create_at"] as? Timestamp
        self = VideoWork(title: data["title"] as? String ?? "",
                         posterPath: data["poster_path"] as? String ?? "",
                         originalName: data["original_name"] as? String ?? "",
                         backdropPath: data["backdrop_path"] as? String ?? "",
                         overview: data["overview"] as? String ?? "",
                         releaseDay: data["releaseDay"] as? String ?? "",
                         reviewStars: data["reviewStars"] as? Double ?? 0.0,
                         review: data["review"] as? String ?? "",
                         createAt: timestamp?.dateValue(),
                         id: data["id"] as? Int ?? 0,
                         isStoredAsReview: data["isStoredAsReview"] as? Bool,
                         mediaType: data["media_type"] as? String)
    }
}
