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
    func didSelectLogin()
}

protocol ReviewMoviePresenterOutput : AnyObject {
    func displayReviewMovie(movieReviewState: MovieReviewStoreState, _ movieReviewElement: MovieReviewElement)
    func displayCastImage(credits: Credits)
    func displayAfterStoreButtonTapped(primaryKeyIsStored: Bool, movieReviewState: MovieReviewStoreState, editing: Bool?, isUpdate: Bool)
    func closeReviewMovieView(movieUpdateState: MovieUpdateState)
    func displayLoggingOutAlert()
    func displayLoginView()
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
        let review = selectedReview.returnReview()
        view.displayReviewMovie(movieReviewState: movieReviewState, review)
        
        model.requestMovieDetail(completion: { [weak self] result in
            switch result {
            case let .success(credits):
                // キャストと監督の情報取得できたら
                DispatchQueue.main.async { [weak self] in
                    self?.view.displayCastImage(credits: credits)
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

    func didSelectLogin() {
        view.displayLoginView()
    }
    func didTapStoreLocationAlert(isStoredAsReview: Bool) { // 初保存で呼ばれる
        selectedReview.update(isSavedAsReview: isStoredAsReview)
        selectedReview.checkTitle()
        let reviewElement = selectedReview.returnReview()
        model.reviewMovie(movieReviewState: movieReviewState, reviewElement)
        NotificationCenter.default.post(name: .insertReview, object: nil)
        view.closeReviewMovieView(movieUpdateState: movieUpdateState)
    }
    
    func didTapSelectStoreDateAlert(storeDateState: storeDateState) { // ストック画面からレビュー画面に変更する
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
            let isLogin = model.checkLoginState()
            if isLogin {
                // 同じものが保存されていないか検証
                let selectedReview = selectedReview.returnReview()
                model.checkSaved(movie: selectedReview) { result in
                    self.selectedReview.update(saveDate: date, score: reviewScore, review: review)
                    self.view.displayAfterStoreButtonTapped(primaryKeyIsStored: result, movieReviewState: self.movieReviewState, editing: editing, isUpdate: true)
                }
            } else {
                view.displayLoggingOutAlert()
            }
            
        case .afterStore(.reviewed):
            guard let editing = editing else { return }
            switch editing {
            case false:
                let isUpdate = selectedReview.checkIsChanged(reviewScore: reviewScore, review: review ?? "")
                if isUpdate {
                    selectedReview.update(score: reviewScore, review: review)
                    let selectedReview = selectedReview.returnReview()
                    model.reviewMovie(movieReviewState: movieReviewState, selectedReview)
                }
                view.displayAfterStoreButtonTapped(primaryKeyIsStored: false, movieReviewState: movieReviewState, editing: editing, isUpdate: isUpdate)

            case true:
                view.displayAfterStoreButtonTapped(primaryKeyIsStored: false, movieReviewState: movieReviewState, editing: editing, isUpdate: true)
            }
            
        case .afterStore(.stock):
            selectedReview.update(isSavedAsReview: true, score: reviewScore, review: review)
            view.displayAfterStoreButtonTapped(primaryKeyIsStored: false, movieReviewState: movieReviewState, editing: editing, isUpdate: true)
        }
    }

    
}
