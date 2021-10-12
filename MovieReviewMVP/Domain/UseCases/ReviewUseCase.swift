//
//  ReviewUseCase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/12.
//

import Foundation

protocol ReviewUseCaseProtocol {
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

final class ReviewUseCase: ReviewUseCaseProtocol {
    
    private let repository: ReviewRepositoryProtocol!
    init(repository: ReviewRepositoryProtocol) {
        self.repository = repository
    }
    
    func checkSaved(movie: MovieReviewElement,
                    completion: @escaping (Bool) -> Void) {
        repository.checkSaved(movie: movie, completion: completion)
    }
    
    func save(movie: MovieReviewElement) {
        repository.save(movie: movie)
    }
    
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        repository.fetch(isStoredAsReview: isStoredAsReview,
                         sortState: sortState,
                         completion: completion)
    }
    
    func sort(isStoredAsReview: Bool,
              sortState: sortState,
              completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        repository.sort(isStoredAsReview: isStoredAsReview,
                        sortState: sortState,
                        completion: completion)
    }
    
    func delete(movie: MovieReviewElement) {
        repository.delete(movie: movie)
    }
    
    func update(movie: MovieReviewElement) {
        repository.update(movie: movie)
    }
    
}
