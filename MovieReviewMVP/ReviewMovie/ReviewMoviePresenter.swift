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
//    func fetchMovieDetail()
}

protocol ReviewMoviePresenterOutput : AnyObject {
    func displayReviewMovie(movieReviewState: MovieReviewStoreState, _ movieReviewElement: MovieReviewElement, credits: Credits)
    func displayAfterStoreButtonTapped(_ primaryKeyIsStored: Bool, _ movieReviewState: MovieReviewStoreState, editing: Bool?)
    func closeReviewMovieView(movieUpdateState: MovieUpdateState)
}

final class ReviewMoviePresenter : ReviewMoviePresenterInput {
    
    private var movieReviewState: MovieReviewStoreState
    private var movieReviewElement: MovieReviewElement
    private var movieUpdateState: MovieUpdateState
    private weak var view: ReviewMoviePresenterOutput!
    private var model: ReviewMovieModelInput
    
//    var castPerson: [CastPersonDetail] = []
//    var crew: CrewDetail?
    
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
        model.requestMovieDetail(completion: { [weak self] result in
            switch result {
            case let .success(credits):
                // キャストと監督の情報取得できたら
                
                DispatchQueue.main.async { [weak self] in
                    guard let state = self?.movieReviewState,
                          let movie = self?.movieReviewElement else { return }
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
    
    func returnMovieReviewElement() -> MovieReviewElement {
        movieReviewElement
    }

    func didTapStoreLocationAlert(isStoredAsReview: Bool) {
        movieReviewElement.isStoredAsReview = isStoredAsReview
        model.reviewMovie(movieReviewState: movieReviewState, movieReviewElement)
        NotificationCenter.default.post(name: .insetReview, object: nil)
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
    
//    func fetchMovieDetail() {
//        model.requestMovieDetail(completion: { [weak self] result in
//            switch result {
//            case let .success(credits):
//                // キャストと監督の情報取得できたら
//
//                DispatchQueue.main.async { [weak self] in
//                    self?.viewDidLoad()
//                }
//            case let .failure(SearchError.requestError(error)):
//                print(error)
//            case let .failure(error):
//                print(error)
//            }
//        })
//    }
    
    
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
        let reviewText = movieReviewElement.review ?? .placeholderString
        if reviewScore != movieReviewElement.reviewStars ?? 0.0 || review != reviewText {
            return true
        }
        return false
    }
    
    func checkReview(review: String?) -> String? {
        if review == "" || review == .placeholderString {
            return nil
        } else {
            return review
        }
    }
}
