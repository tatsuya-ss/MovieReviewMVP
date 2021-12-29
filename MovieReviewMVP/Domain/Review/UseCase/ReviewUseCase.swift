//
//  ReviewUseCase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/12.
//

import Foundation

protocol ReviewUseCaseProtocol {
    func checkSaved(movie: VideoWork,
                    completion: @escaping (Bool) -> Void)
    func save(movie: VideoWork)
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[VideoWork], Error>) -> Void)
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[VideoWork], Error>) -> Void)
    func delete(movie: VideoWork)
    func update(movie: VideoWork)
}

final class ReviewUseCase: ReviewUseCaseProtocol {
    
    private let repository: ReviewRepositoryProtocol!
    init(repository: ReviewRepositoryProtocol) {
        self.repository = repository
    }
    
    func checkSaved(movie: VideoWork,
                    completion: @escaping (Bool) -> Void) {
        repository.checkSaved(movie: movie, completion: completion)
    }
    
    func save(movie: VideoWork) {
        repository.save(movie: movie)
    }
    
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[VideoWork], Error>) -> Void) {
        repository.fetch(isStoredAsReview: isStoredAsReview,
                         sortState: sortState,
                         completion: completion)
    }
    
    func sort(isStoredAsReview: Bool,
              sortState: sortState,
              completion: @escaping (Result<[VideoWork], Error>) -> Void) {
        repository.sort(isStoredAsReview: isStoredAsReview,
                        sortState: sortState,
                        completion: completion)
    }
    
    func delete(movie: VideoWork) {
        repository.delete(movie: movie)
    }
    
    func update(movie: VideoWork) {
        repository.update(movie: movie)
    }
    
}
