//
//  StockReviewMovieManagementModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/16.
//

import Foundation

protocol StockReviewMovieManagementModelInput {
    func fetchStockMovies(sortState: sortState) -> [MovieReviewElement]
}

final class StockReviewMovieManagementModel : StockReviewMovieManagementModelInput {
    let movieUseCase = MovieUseCase()
    
    func fetchStockMovies(sortState: sortState) -> [MovieReviewElement] {
        movieUseCase.fetch(sortState, isStoredAsReview: false)
    }
}
