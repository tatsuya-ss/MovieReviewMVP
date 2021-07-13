//
//  StockReviewMovieManagementModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/16.
//

import Foundation

protocol StockReviewMovieManagementModelInput {
    func delete(movie: MovieReviewElement)
    func fetch(isStoredAsReview: Bool, sortState: sortState,  completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
}

final class StockReviewMovieManagementModel : StockReviewMovieManagementModelInput {
//    let movieUseCase = MovieUseCase()
    let reviewUseCase = ReviewUseCase()
    
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


    func delete(movie: MovieReviewElement) {
        reviewUseCase.delete(movie: movie)
    }
}
