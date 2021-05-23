//
//  ReviewMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMoviePresenterInput {
    func viewDidLoad()
    func didTapSaveButton(reviewScore: Double, review: String)
    func returnMovieReviewState() -> MovieReviewState
}

protocol ReviewMoviePresenterOutput : AnyObject {
    func displayReviewMovie(movieReviewState: MovieReviewState, _ movieInfomation: MovieReviewElement)
}

final class ReviewMoviePresenter : ReviewMoviePresenterInput {
    func returnMovieReviewState() -> MovieReviewState {
        movieReviewState
    }
    
    
    private var movieReviewState: MovieReviewState
    private var movieReviewElement: MovieReviewElement

    
    private weak var view: ReviewMoviePresenterOutput!
    private var model: ReviewMovieModelInput
    
    init(movieReviewState: MovieReviewState, movieReviewElement: MovieReviewElement, view: ReviewMoviePresenterOutput, model: ReviewMovieModelInput) {
        self.movieReviewState = movieReviewState
        self.movieReviewElement = movieReviewElement
        self.view = view
        self.model = model
    }

    // MARK: viewDidLoad時
    func viewDidLoad() {
        switch movieReviewState {
        case .beforeStore:
            self.view.displayReviewMovie(movieReviewState: movieReviewState, movieReviewElement)
        case .afterStore:
            self.view.displayReviewMovie(movieReviewState: movieReviewState, movieReviewElement)
            print(movieReviewElement)
        }
    }
    
    // MARK: 保存ボタンが押された時の処理
    func didTapSaveButton(reviewScore: Double, review: String) {

        movieReviewElement.reviewStars = reviewScore
        movieReviewElement.review = review
        
        switch movieReviewState {
        case .beforeStore:
            model.createMovieReview(movieReviewElement)
        case .afterStore:
            model.modificateMovieReview(movieReviewElement)
        }
    }
}
