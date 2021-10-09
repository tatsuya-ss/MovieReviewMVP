//
//  ReviewMovieModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMovieModelInput {
    func checkSaved(movie: MovieReviewElement, completion: @escaping (Bool) -> Void)
    func reviewMovie(movieReviewState: MovieReviewStoreState, _ movie: MovieReviewElement)
    func fetchMovie(sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
    func checkLoginState() -> Bool
}

final class ReviewMovieModel : ReviewMovieModelInput {
    
    private var movieReviewElement: MovieReviewElement?
    init(movie: MovieReviewElement?, movieReviewElement: MovieReviewElement?) {
        self.movieReviewElement = movie
    }
    
    let reviewUseCase = ReviewUseCase()
    
    func checkSaved(movie: MovieReviewElement, completion: @escaping (Bool) -> Void) {
        reviewUseCase.checkSaved(movie: movie) { result in
            completion(result)
        }
    }
    
    func checkLoginState() -> Bool {
        reviewUseCase.returnloginStatus()
    }
    
    func reviewMovie(movieReviewState: MovieReviewStoreState, _ movie: MovieReviewElement) {
        switch movieReviewState {
        case .beforeStore:
            reviewUseCase.save(movie: movie)
        case .afterStore:
            reviewUseCase.update(movie: movie)
        }
        
    }
    
    func fetchMovie(sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        reviewUseCase.fetch(isStoredAsReview: nil, sortState: sortState) { result in
            completion(result)
        }
    }
}
