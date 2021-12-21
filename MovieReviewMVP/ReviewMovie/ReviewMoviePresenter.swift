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
    func displayReviewMovie(title: String, releaseDay: String, rating: Double, posterData: Data?, review: String?, overview: String?)
    func displayCastImage(casts: [CastDetail])
    func displayAfterStoreButtonTapped(primaryKeyIsStored: Bool, movieReviewState: MovieReviewStoreState, editing: Bool?, isUpdate: Bool)
    func closeReviewMovieView(movieUpdateState: MovieUpdateState)
    func displayLoggingOutAlert()
    func displayLoginView()
}

final class ReviewMoviePresenter : ReviewMoviePresenterInput {
    
    private var movieReviewState: MovieReviewStoreState
    private var movieUpdateState: MovieUpdateState
    private let selectedReview: SelectedReview
    private var casts: [CastDetail] = []
    
    private weak var view: ReviewMoviePresenterOutput!
    private let videoWorkUseCase: VideoWorkUseCaseProtocol
    private let reviewUseCase: ReviewUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol
    
    init(movieReviewState: MovieReviewStoreState,
         movieReviewElement: MovieReviewElement,
         movieUpdateState: MovieUpdateState,
         view: ReviewMoviePresenterOutput,
         videoWorkuseCase: VideoWorkUseCaseProtocol,
         reviewUseCase: ReviewUseCaseProtocol,
         userUseCase: UserUseCaseProtocol) {
        selectedReview = SelectedReview(review: movieReviewElement)
        self.movieReviewState = movieReviewState
        self.movieUpdateState = movieUpdateState
        self.view = view
        self.videoWorkUseCase = videoWorkuseCase
        self.reviewUseCase = reviewUseCase
        self.userUseCase = userUseCase
    }
    
    private func makeTitle(movie: MovieReviewElement) -> String {
        if let title = movie.title, !title.isEmpty {
            return title
        } else if let originalName = movie.original_name, !originalName.isEmpty {
            return originalName
        } else {
            return .notTitle
        }
    }
        
    private func makeReleaseDateText(movie: MovieReviewElement) -> String {
        if let releaseDay = movie.releaseDay,
           !releaseDay.isEmpty {
            return " " + "公開日" + " " + releaseDay
        } else {
            return " " + "公開日未定"
        }
    }
    
    func viewDidLoad() {
        // MARK: レビュー情報の表示
        let review = selectedReview.getReview()
        let title = makeTitle(movie: review)
        let releaseDay = makeReleaseDateText(movie: review)
        let rating = review.reviewStars ?? 3.0
        view.displayReviewMovie(title: title, releaseDay: releaseDay, rating: rating, posterData: review.posterData, review: review.review, overview: review.overview)
        
        // MARK: キャスト情報取得してViewを更新
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        videoWorkUseCase.fetchVideoWorkDetail(videoWork: review) { [weak self] result in
            defer { dispatchGroup.leave() }
            switch result {
            case .failure(let error):
                print(error)
            case .success(let casts):
                self?.casts = casts
                casts.enumerated().forEach { cast in
                    dispatchGroup.enter()
                    self?.videoWorkUseCase.fetchPosterImage(posterPath: cast.element.profile_path) {
                        result in
                        defer { dispatchGroup.leave() }
                        switch result {
                        case .failure(let error):
                            print(error)
                        case .success(let data):
                            self?.casts[cast.offset].posterData = data
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self?.view.displayCastImage(casts: self?.casts ?? [])
                }
                
            }
        }
    }
    
    // MARK: どこから画面遷移されたのかをenumで区別
    func returnMovieReviewState() -> MovieReviewStoreState {
        movieReviewState
    }
    
    func returnMovieUpdateState() -> MovieUpdateState {
        movieUpdateState
    }
    
    func returnMovieReviewElement() -> MovieReviewElement? {
        selectedReview.getReview()
    }
    
    func didSelectLogin() {
        view.displayLoginView()
    }
    func didTapStoreLocationAlert(isStoredAsReview: Bool) { // 初保存で呼ばれる
        selectedReview.update(isSavedAsReview: isStoredAsReview)
        selectedReview.checkTitle()
        let reviewElement = selectedReview.getReview()
        switch movieReviewState {
        case .beforeStore:
            reviewUseCase.save(movie: reviewElement)
        case .afterStore:
            reviewUseCase.update(movie: reviewElement)
        }
        NotificationCenter.default.post(name: .insertReview, object: nil)
        UserDefaults.standard.saveNumberOfSaves()
        view.closeReviewMovieView(movieUpdateState: movieUpdateState)
    }
    
    func didTapSelectStoreDateAlert(storeDateState: storeDateState) { // ストック画面からレビュー画面に変更する
        if case .today = storeDateState {
            selectedReview.update(saveDate: Date())
        }
        let reviewElement = selectedReview.getReview()
        reviewUseCase.update(movie: reviewElement)
        NotificationCenter.default.post(name: .insertReview, object: nil)
        view.closeReviewMovieView(movieUpdateState: movieUpdateState)
    }
    
    
    // MARK: 保存・更新ボタンが押された時の処理
    func didTapUpdateButton(editing: Bool?, date: Date, reviewScore: Double, review: String?) {
        switch movieReviewState {
        case .beforeStore:
            let isLogin = userUseCase.returnloginStatus()
            if isLogin {
                // 同じものが保存されていないか検証
                let selectedReview = selectedReview.getReview()
                reviewUseCase.checkSaved(movie: selectedReview) { result in
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
                    let selectedReview = selectedReview.getReview()
                    reviewUseCase.update(movie: selectedReview)
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
