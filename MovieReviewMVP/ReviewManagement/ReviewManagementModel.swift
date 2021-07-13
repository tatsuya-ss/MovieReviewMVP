//
//  ReviewManagementModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/09.
//

import Foundation

protocol ReviewManagementModelInput {
    func delete(movie: MovieReviewElement)
    func fetch(isStoredAsReview: Bool, sortState: sortState,  completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
}

class ReviewManagementModel : ReviewManagementModelInput {
    let reviewUseCase = ReviewUseCase()
    
    func delete(movie: MovieReviewElement) {
        reviewUseCase.delete(movie: movie)
    }
    
    func fetch(isStoredAsReview: Bool, sortState: sortState,  completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        reviewUseCase.fetch(isStoredAsReview: isStoredAsReview, sortState: sortState) { result in
            switch result {
            case .success(let reviews):
                completion(.success(reviews))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        reviewUseCase.sort(isStoredAsReview: isStoredAsReview, sortState: sortState) { result in
            switch result {
            case .success(let reviews):
                completion(.success(reviews))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
