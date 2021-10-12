//
//  ReviewRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/12.
//

import Foundation

protocol FirebaseRepositoryProtocol {
    func checkSaved(movie: MovieReviewElement,
                    completion: @escaping (Bool) -> Void)
    func save(movie: MovieReviewElement)
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)

}

final class FirebaseRepository: FirebaseRepositoryProtocol {
    
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
            <#code#>
        }
    }
}
