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
    func returnMovieReviewState() -> MovieReviewStoreState
    func didTapStoreLocationAlert(isStoredAsReview: Bool)
    func didTapSelectStoreDateAlert(storeDateState: storeDateState)
    func returnMovieUpdateState() -> MovieUpdateState
}

protocol ReviewMoviePresenterOutput : AnyObject {
    func displayReviewMovie(movieReviewState: MovieReviewStoreState, _ movieInfomation: MovieReviewElement)
    func displayAfterStoreButtonTapped(_ primaryKeyIsStored: Bool, _ movieReviewState: MovieReviewStoreState)
    func closeReviewMovieView(movieUpdateState: MovieUpdateState)
}

final class ReviewMoviePresenter : ReviewMoviePresenterInput {
    
    private var movieReviewState: MovieReviewStoreState
    private var movieReviewElement: MovieReviewElement
    private var movieUpdateState: MovieUpdateState
    private weak var view: ReviewMoviePresenterOutput!
    private var model: ReviewMovieModelInput
    
    init(movieReviewState: MovieReviewStoreState,
         movieReviewElement: MovieReviewElement,
         movieUpdateState: MovieUpdateState,
         view: ReviewMoviePresenterOutput,
         model: ReviewMovieModelInput) {
        self.movieReviewState = movieReviewState
        self.movieReviewElement = movieReviewElement
        self.movieUpdateState = movieUpdateState
        self.view = view
        self.model = model
    }

    // MARK: viewDidLoad時
    func viewDidLoad() {
        view.displayReviewMovie(movieReviewState: movieReviewState, movieReviewElement)
    }
    
    // MARK: どこから画面遷移されたのかをenumで区別
    func returnMovieReviewState() -> MovieReviewStoreState {
        movieReviewState
    }

    func returnMovieUpdateState() -> MovieUpdateState {
        movieUpdateState
    }
    
    // MARK: 保存ボタンが押された時の処理
    func didTapSaveButton(date: Date, reviewScore: Double, review: String) {
        
        var primaryKeyIsStored = false

        switch movieReviewState {
        case .beforeStore:  // プライマリーキーが被っていないかの検証
            let movies = model.fetchMovie(sortState: .createdAscend)
            for movie in movies {
                guard movie.id != movieReviewElement.id else { primaryKeyIsStored = true; break }
            }
            if primaryKeyIsStored == false {  // まだ保存していない場合
                movieReviewElement.create_at = date
                movieReviewElement.reviewStars = reviewScore
                movieReviewElement.review = review
            }
            
        case .afterStore(.reviewed):
            movieReviewElement.reviewStars = reviewScore
            movieReviewElement.review = review
            // realmのデータ更新
            model.reviewMovie(movieReviewState: movieReviewState, movieReviewElement)

        case .afterStore(.stock):
            movieReviewElement.reviewStars = reviewScore
            movieReviewElement.review = review
            movieReviewElement.isStoredAsReview = true
        }
        
        view.displayAfterStoreButtonTapped(primaryKeyIsStored, movieReviewState)
    }
    
    func didTapStoreLocationAlert(isStoredAsReview: Bool) {
        movieReviewElement.isStoredAsReview = isStoredAsReview
        model.reviewMovie(movieReviewState: movieReviewState, movieReviewElement)
        view.closeReviewMovieView(movieUpdateState: movieUpdateState)
    }
    
    func didTapSelectStoreDateAlert(storeDateState: storeDateState) {
        switch storeDateState {
        case .stockDate:
            break
        case .today:
            movieReviewElement.create_at = Date()
        }
        model.reviewMovie(movieReviewState: movieReviewState, movieReviewElement)
        view.closeReviewMovieView(movieUpdateState: movieUpdateState)
    }
    
}
