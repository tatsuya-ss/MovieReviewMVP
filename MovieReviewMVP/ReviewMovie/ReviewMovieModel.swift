//
//  ReviewMovieModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMovieModelInput {
    func reviewMovie(movieReviewState: MovieReviewState, _ movie: MovieReviewElement)
}

final class ReviewMovieModel : ReviewMovieModelInput {
    
    
    private var movieReviewElement: MovieReviewElement?
    init(movie: MovieReviewElement?, movieReviewElement: MovieReviewElement?) {
        self.movieReviewElement = movie
    }
    
    func reviewMovie(movieReviewState: MovieReviewState, _ movie: MovieReviewElement) {
        
        let movieUseCase = MovieUseCase()

        switch movieReviewState {
        case .beforeStore:
            movieUseCase.create(movie)
        case .afterStore:
            movieUseCase.update(movie)
        }
        
    }

    
}
