//
//  ReviewMovieModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMovieModelInput {
    func createMovieReview(_ movie: MovieReviewElement)
    func modificateMovieReview(_ movie: MovieReviewElement)

}

final class ReviewMovieModel : ReviewMovieModelInput {
    
    private var movieReviewElement: MovieReviewElement?
    init(movie: MovieReviewElement?, movieReviewElement: MovieReviewElement?) {
        self.movieReviewElement = movie
    }
    
    func createMovieReview(_ movie: MovieReviewElement) {
        let movieUseCase = MovieUseCase()
        movieUseCase.create(movie)
    }
    
    func modificateMovieReview(_ movie: MovieReviewElement) {
        let movieUseCase = MovieUseCase()
        movieUseCase.update(movie)
    }
    
}
