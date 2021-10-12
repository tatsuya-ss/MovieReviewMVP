//
//  ReviewRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/12.
//

import Foundation

protocol ReviewRepositoryProtocol {
    func checkSaved(movie: MovieReviewElement,
                    completion: @escaping (Bool) -> Void)
    func save(movie: MovieReviewElement)
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
    func delete(movie: MovieReviewElement)
    func update(movie: MovieReviewElement)
}

final class ReviewRepository: ReviewRepositoryProtocol {
    
    let dataStore: FirebaseDataStoreProtocol!
    init(dataStore: FirebaseDataStoreProtocol) {
        self.dataStore = dataStore
    }
    
    func checkSaved(movie: MovieReviewElement,
                    completion: @escaping (Bool) -> Void) {
        dataStore.checkSaved(movie: movie, completion: completion)
    }
    
    func save(movie: MovieReviewElement) {
        dataStore.save(movie: movie)
    }
    
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        dataStore.fetch(isStoredAsReview: isStoredAsReview,
                        sortState: sortState) { result in
            switch result {
            case .success(let data):
                let videoWorks = data.map { MovieReviewElement(data: $0) }
                completion(.success(videoWorks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sort(isStoredAsReview: Bool,
              sortState: sortState,
              completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        dataStore.sort(isStoredAsReview: isStoredAsReview,
                       sortState: sortState) { result in
            switch result {
            case .success(let data):
                let videoWorks = data.map { MovieReviewElement(data: $0) }
                completion(.success(videoWorks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func delete(movie: MovieReviewElement) {
        dataStore.delete(movie: movie)
    }
    
    func update(movie: MovieReviewElement) {
        dataStore.update(movie: movie)
    }
    
}

private extension MovieReviewElement {
    init(data: [String: Any]) {
        self = MovieReviewElement(title: data["title"] as? String ?? "",
                                  poster_path: data["poster_path"] as? String ?? "",
                                  original_name: data["original_name"] as? String ?? "",
                                  backdrop_path: data["backdrop_path"] as? String ?? "",
                                  overview: data["overview"] as? String ?? "",
                                  releaseDay: data["releaseDay"] as? String ?? "",
                                  reviewStars: data["reviewStars"] as? Double ?? 0.0,
                                  review: data["review"] as? String ?? "",
                                  create_at: data["create_at"] as? Date,
                                  id: data["id"] as? Int ?? 0,
                                  isStoredAsReview: data["isStoredAsReview"] as? Bool,
                                  media_type: data["media_type"] as? String)
    }
}
