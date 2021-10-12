//
//  ReviewUseCase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/12.
//

import Foundation

final class FirebaseUseCase {
    private var repository: FirebaseDataStoreProtocol
    
    init(repository: FirebaseDataStoreProtocol = FirebaseDataStore()) {
        self.repository = repository
    }
    
    func checkSaved(movie: MovieReviewElement, completion: @escaping (Bool) -> Void) {
        repository.checkSaved(movie: movie) { result in
            completion(result)
        }
    }
    
    func save(movie: MovieReviewElement) {
        repository.save(movie: movie)
    }

    func fetch(isStoredAsReview: Bool?, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        repository.fetch(isStoredAsReview: isStoredAsReview, sortState: sortState) { result in
            completion(result)
        }
    }
    
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        repository.sort(isStoredAsReview: isStoredAsReview, sortState: sortState) { result in
            completion(result)
        }
    }

    
    func delete(movie: MovieReviewElement) {
        repository.delete(movie: movie)
    }

    func update(movie: MovieReviewElement) {
        repository.update(movie: movie)
    }
    
    func returnProfileInfomations() -> (String?, URL?) {
        repository.returnProfileInfomations()
    }
    
    func logout() {
        repository.logout()
    }
    
    func returnCurrentUserEmail() -> String? {
        repository.returnCurrentUserEmail()
    }
    
    func returnloginStatus() -> Bool {
        repository.returnloginStatus()
    }
}
