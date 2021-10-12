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
    
    let reviewUseCase = ReviewUseCase(repository: ReviewRepository(dataStore: ReviewDataStore()))

    func fetch(isStoredAsReview: Bool, sortState: sortState,  completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        reviewUseCase.fetch(isStoredAsReview: isStoredAsReview, sortState: sortState) { result in
            completion(result)
        }
        
    }
    
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        reviewUseCase.sort(isStoredAsReview: isStoredAsReview, sortState: sortState) { result in
            completion(result)
        }
    }


    func delete(movie: MovieReviewElement) {
        reviewUseCase.delete(movie: movie)
    }
}
