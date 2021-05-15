//
//  ReviewMovieModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMovieModelInput {
    func createMovieReview(_ movie: MovieReviewElement)
}

final class ReviewMovieModel : ReviewMovieModelInput {
    
    private let movieInfomation: MovieInfomation!
    init(movie: MovieInfomation) {
        self.movieInfomation = movie
    }
    
    func createMovieReview(_ movie: MovieReviewElement) {
        let movieUseCase = MovieUseCase()
        movieUseCase.create(movie)
    }

}
