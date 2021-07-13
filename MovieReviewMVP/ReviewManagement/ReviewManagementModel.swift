//
//  ReviewManagementModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/09.
//

import Foundation

protocol ReviewManagementModelInput {
//    func deleteReviewMovie(_ sortState: sortState, _ id: Int)
    func delete(movie: MovieReviewElement)
//    func sortReview(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement]
//    func fetchReviewMovie(_ sortState: sortState, isStoredAsReview: Bool) -> [MovieReviewElement]
    // firebase
    func fetch(isStoredAsReview: Bool, sortState: sortState,  completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
}

class ReviewManagementModel : ReviewManagementModelInput {
//    let movieUseCase = MovieUseCase()
    let reviewUseCase = ReviewUseCase()

//    func deleteReviewMovie(_ sortState: sortState, _ id: Int) {
//        movieUseCase.delete(sortState, id)
//    }
    
    func delete(movie: MovieReviewElement) {
        reviewUseCase.delete(movie: movie)
    }
    
//    func sortReview(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement] {
//        movieUseCase.sort(sortState, isStoredAsReview: isStoredAsReview)
//    }

//    func fetchReviewMovie(_ sortState: sortState, isStoredAsReview: Bool) -> [MovieReviewElement] {
//        movieUseCase.fetch(sortState, isStoredAsReview: isStoredAsReview)
//    }
    
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
