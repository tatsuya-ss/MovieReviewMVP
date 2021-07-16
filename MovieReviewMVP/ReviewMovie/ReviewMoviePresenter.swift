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
    func returnMovieReviewElement() -> MovieReviewElement?
}

protocol ReviewMoviePresenterOutput : AnyObject {
    func displayReviewMovie(movieReviewState: MovieReviewStoreState, _ movieReviewElement: MovieReviewElement, credits: Credits)
    func displayAfterStoreButtonTapped(_ primaryKeyIsStored: Bool, _ movieReviewState: MovieReviewStoreState, editing: Bool?)
    func closeReviewMovieView(movieUpdateState: MovieUpdateState)
}

final class ReviewMoviePresenter : ReviewMoviePresenterInput {
    
    private var movieReviewState: MovieReviewStoreState
    private var movieUpdateState: MovieUpdateState
    private let selectedReview: SelectedReview

    private weak var view: ReviewMoviePresenterOutput!
    private var model: ReviewMovieModelInput
    
    init(movieReviewState: MovieReviewStoreState,
         movieReviewElement: MovieReviewElement,
         movieUpdateState: MovieUpdateState,
         view: ReviewMoviePresenterOutput,
         model: ReviewMovieModelInput) {
        selectedReview = SelectedReview(review: movieReviewElement)
        self.movieReviewState = movieReviewState
        self.movieUpdateState = movieUpdateState
        self.view = view
        self.model = model
    }

    // MARK: viewDidLoad時
    func viewDidLoad() {
        model.requestMovieDetail(completion: { [weak self] result in
            switch result {
            case let .success(credits):
                // キャストと監督の情報取得できたら
                DispatchQueue.main.async { [weak self] in
                    guard let state = self?.movieReviewState,
                          let movie = self?.selectedReview.returnReview() else { return }
                    self?.view.displayReviewMovie(movieReviewState: state, movie, credits: credits)
                }
            case let .failure(SearchError.requestError(error)):
                print(error)
            case let .failure(error):
                print(error)
            }
        })
    }
    
    // MARK: どこから画面遷移されたのかをenumで区別
    func returnMovieReviewState() -> MovieReviewStoreState {
        movieReviewState
    }

    func returnMovieUpdateState() -> MovieUpdateState {
        movieUpdateState
    }
    
    func returnMovieReviewElement() -> MovieReviewElement? {
        selectedReview.returnReview()
    }

    func didTapStoreLocationAlert(isStoredAsReview: Bool) { // 初保存で呼ばれる
        selectedReview.update(isSavedAsReview: isStoredAsReview)
        let reviewElement = selectedReview.returnReview()
        model.reviewMovie(movieReviewState: movieReviewState, reviewElement)
        NotificationCenter.default.post(name: .insetReview, object: nil)
        view.closeReviewMovieView(movieUpdateState: movieUpdateState)
    }
    
    func didTapSelectStoreDateAlert(storeDateState: storeDateState) {
        if case .today = storeDateState {
            selectedReview.update(saveDate: Date())
        }
        let reviewElement = selectedReview.returnReview()
        model.reviewMovie(movieReviewState: movieReviewState, reviewElement)
        view.closeReviewMovieView(movieUpdateState: movieUpdateState)
    }
    
    
    // MARK: 保存・更新ボタンが押された時の処理
    func didTapUpdateButton(editing: Bool?, date: Date, reviewScore: Double, review: String?) {
        switch movieReviewState {
        case .beforeStore:
            // プライマリーキーが被っていないかの検証
            let selectedReview = selectedReview.returnReview()
            model.checkSaved(movie: selectedReview) { result in
                switch result {
                case true:
                    self.view.displayAfterStoreButtonTapped(true, self.movieReviewState, editing: editing)
                case false:
                    self.selectedReview.update(saveDate: date, score: reviewScore, review: review)
                    self.view.displayAfterStoreButtonTapped(false, self.movieReviewState, editing: editing)
                }
            }
            
        case .afterStore(.reviewed):
            guard let editing = editing else { return }
            switch editing {
            case false:
                let isChanged = selectedReview.checkIsChanged(reviewScore: reviewScore, review: review ?? "")
                if isChanged {
                    selectedReview.update(score: reviewScore, review: review)
                    let selectedReview = selectedReview.returnReview()
                    model.reviewMovie(movieReviewState: movieReviewState, selectedReview)
                    view.displayAfterStoreButtonTapped(false, movieReviewState, editing: editing)
                }
            case true:
                view.displayAfterStoreButtonTapped(false, movieReviewState, editing: editing)
            }
            
        case .afterStore(.stock):
            selectedReview.update(isSavedAsReview: true, score: reviewScore, review: review)
            let selectedReview = selectedReview.returnReview()
            model.reviewMovie(movieReviewState: movieReviewState, selectedReview)
            view.displayAfterStoreButtonTapped(false, movieReviewState, editing: editing)
        }
    }

    
}
