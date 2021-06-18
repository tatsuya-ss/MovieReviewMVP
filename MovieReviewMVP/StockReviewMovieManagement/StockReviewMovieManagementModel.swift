//
//  StockReviewMovieManagementModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/16.
//

import Foundation

protocol StockReviewMovieManagementModelInput {
    func fetchStockMovies(sortState: sortState) -> [MovieReviewElement]
    func sortReview(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement]
    func deleteReviewMovie(_ sortState: sortState, _ id: Int)
}

final class StockReviewMovieManagementModel : StockReviewMovieManagementModelInput {
    let movieUseCase = MovieUseCase()
    
    func fetchStockMovies(sortState: sortState) -> [MovieReviewElement] {
        movieUseCase.fetch(sortState, isStoredAsReview: false)
    }
    
    func sortReview(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement] {
        movieUseCase.sort(sortState, isStoredAsReview: isStoredAsReview)
    }

    func deleteReviewMovie(_ sortState: sortState, _ id: Int) {
        movieUseCase.delete(sortState, id)
    }
}
