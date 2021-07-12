//
//  ReviewUseCase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/12.
//

import Foundation

final class ReviewUseCase {
    private var repository: ReviewRepository
    
    init(repository: ReviewRepository = Firebase()) {
        self.repository = repository
    }
    
    func save(movie: MovieReviewElement) {
        repository.save(movie: movie)
    }

    func fetch(sortState: sortState, isStoredAsReview: Bool?, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        repository.fetch(sortState: sortState,
                         isStoredAsReview: isStoredAsReview) { result in
            switch result {
            case .success(let reviews):
                completion(.success(reviews))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func delete(movie: MovieReviewElement) {
        repository.delete(movie: movie)
    }

}
