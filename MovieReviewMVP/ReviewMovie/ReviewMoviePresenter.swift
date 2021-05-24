//
//  ReviewMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMoviePresenterInput {
    func viewDidLoad()
    func didTapSaveButton(date: Date, reviewScore: Double, review: String)
    func returnMovieReviewState() -> MovieReviewState
}

protocol ReviewMoviePresenterOutput : AnyObject {
    func displayReviewMovie(movieReviewState: MovieReviewState, _ movieInfomation: MovieReviewElement)
}

final class ReviewMoviePresenter : ReviewMoviePresenterInput {
    
    
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
        }
    }
    
    // MARK: どこから画面遷移されたのかをenumで区別
    func returnMovieReviewState() -> MovieReviewState {
        movieReviewState
    }

    
    // MARK: 保存ボタンが押された時の処理
    func didTapSaveButton(date: Date, reviewScore: Double, review: String) {
        
        switch movieReviewState {
        case .beforeStore:
            movieReviewElement.create_at = date
            movieReviewElement.reviewStars = reviewScore
            movieReviewElement.review = review
            print(movieReviewElement.create_at)
            
        case .afterStore:
            movieReviewElement.reviewStars = reviewScore
            movieReviewElement.review = review
            print(movieReviewElement.create_at)
        }

        model.reviewMovie(movieReviewState: movieReviewState, movieReviewElement)

    }
}
