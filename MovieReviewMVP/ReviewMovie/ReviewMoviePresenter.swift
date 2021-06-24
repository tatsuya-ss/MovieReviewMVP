//
//  ReviewMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMoviePresenterInput {
    func viewDidLoad()
    func didTapUpdateButton(editing: Bool?, date: Date, reviewScore: Double, review: String?)
    func returnMovieReviewState() -> MovieReviewStoreState
    func didTapStoreLocationAlert(isStoredAsReview: Bool)
    func didTapSelectStoreDateAlert(storeDateState: storeDateState)
    func returnMovieUpdateState() -> MovieUpdateState
    func returnMovieReviewElement() -> MovieReviewElement
}

protocol ReviewMoviePresenterOutput : AnyObject {
    func displayReviewMovie(movieReviewState: MovieReviewStoreState, _ movieInfomation: MovieReviewElement)
    func displayAfterStoreButtonTapped(_ primaryKeyIsStored: Bool, _ movieReviewState: MovieReviewStoreState, editing: Bool?)
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
    
    func returnMovieReviewElement() -> MovieReviewElement {
        movieReviewElement
    }
    
    // MARK: 保存・更新ボタンが押された時の処理
    func didTapUpdateButton(editing: Bool?, date: Date, reviewScore: Double, review: String?) {
        var primaryKeyIsStored = false

        switch movieReviewState {
        case .beforeStore:  // プライマリーキーが被っていないかの検証
            primaryKeyIsStored = checkPrimaryKey()
            if primaryKeyIsStored == false {  // まだ保存していない場合
                movieReviewElement.create_at = date
                movieReviewElement.reviewStars = reviewScore
                movieReviewElement.review = checkReview(review: review)
            }
            
        case .afterStore(.reviewed):
            guard let editing = editing else { return }
            switch editing {
            case false:
                let isChange = checkIsChange(reviewScore: reviewScore, review: review)
                if isChange {
                    movieReviewElement.review = checkReview(review: review)
                    movieReviewElement.reviewStars = reviewScore
                    model.reviewMovie(movieReviewState: movieReviewState, movieReviewElement)
                }
                                
            case true:
                break
            }
            
        case .afterStore(.stock):
            movieReviewElement.reviewStars = reviewScore
            movieReviewElement.review = checkReview(review: review)
            movieReviewElement.isStoredAsReview = true
        }
        view.displayAfterStoreButtonTapped(primaryKeyIsStored, movieReviewState, editing: editing)
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

extension ReviewMoviePresenter {
    func checkPrimaryKey() -> Bool {
        let movies = model.fetchMovie(sortState: .createdAscend)
        for movie in movies {
            guard movie.id != movieReviewElement.id else { return true }
        }
        return false
    }
    
    func checkIsChange(reviewScore: Double, review: String?) -> Bool {
        let reviewText = movieReviewElement.review ?? "レビューを入力してください"
        if reviewScore != movieReviewElement.reviewStars ?? 0.0 || review != reviewText {
            return true
        }
        return false
    }
    
    func checkReview(review: String?) -> String? {
        if review == "" || review == "レビューを入力してください" {
            return nil
        } else {
            return review
        }
    }
}
