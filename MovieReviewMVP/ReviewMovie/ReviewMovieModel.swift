//
//  ReviewMovieModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMovieModelInput {
    func reviewMovie(movieReviewState: MovieReviewState, _ movie: MovieReviewElement)
    
    func fetchMovie(sortState: sortState) -> [MovieReviewElement]
}

final class ReviewMovieModel : ReviewMovieModelInput {
    
    
    private var movieReviewElement: MovieReviewElement?
    init(movie: MovieReviewElement?, movieReviewElement: MovieReviewElement?) {
        self.movieReviewElement = movie
    }
    
    let movieUseCase = MovieUseCase()

    func reviewMovie(movieReviewState: MovieReviewState, _ movie: MovieReviewElement) {
        

        switch movieReviewState {
        case .beforeStore:
            movieUseCase.create(movie)
        case .afterStore:
            movieUseCase.update(movie)
        }
        
    }
    
    func fetchMovie(sortState: sortState) -> [MovieReviewElement] {
        movieUseCase.fetch(sortState, isStoredAsReview: nil)
    }

    
}
