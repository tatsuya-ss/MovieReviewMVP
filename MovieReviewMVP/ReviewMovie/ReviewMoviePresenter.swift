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
    func didTapStoreLocationAlert(_ isStoredAsReview: Bool)
}

protocol ReviewMoviePresenterOutput : AnyObject {
    func displayReviewMovie(movieReviewState: MovieReviewState, _ movieInfomation: MovieReviewElement)
    func displayAfterStoreButtonTapped(_ primaryKeyIsStored: Bool, _ movieReviewState: MovieReviewState)
    func closeReviewMovieView()
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
        
        var primaryKeyIsStored = false

        switch movieReviewState {
        case .beforeStore:
            // プライマリーキーが被っていないかの検証
            let movies = model.fetchMovie(sortState: .createdAscend)
            for movie in movies {
                if primaryKeyIsStored == false {
                    movie.id == movieReviewElement.id ? (primaryKeyIsStored = true) : (primaryKeyIsStored = false)
                } else {
                    break
                }
            }
            
            if primaryKeyIsStored == false {
                // まだ保存していない場合
                movieReviewElement.create_at = date
                movieReviewElement.reviewStars = reviewScore
                movieReviewElement.review = review
            }

        case .afterStore:
            primaryKeyIsStored = false
            movieReviewElement.reviewStars = reviewScore
            movieReviewElement.review = review
            model.reviewMovie(movieReviewState: movieReviewState, movieReviewElement)
        }
        
        view.displayAfterStoreButtonTapped(primaryKeyIsStored, movieReviewState)
    }
    
    func didTapStoreLocationAlert(_ isStoredAsReview: Bool) {
        movieReviewElement.isStoredAsReview = isStoredAsReview
        model.reviewMovie(movieReviewState: movieReviewState, movieReviewElement)
        view.closeReviewMovieView()
    }
    
}
