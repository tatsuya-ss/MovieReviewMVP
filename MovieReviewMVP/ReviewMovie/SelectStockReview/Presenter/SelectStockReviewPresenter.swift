//
//  SelectStockReviewPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/12/25.
//

import Foundation

protocol SelectStockReviewPresenterInput {
    func viewDidLoad()
}

protocol SelectStockReviewPresenterOutput: AnyObject {
    func viewDidLoad(title: String, releaseDay: String, rating: Double, posterData: Data?, review: String?, overview: String?)
    func displayCastImage(casts: [CastDetail])
}

final class SelectStockReviewPresenter: SelectStockReviewPresenterInput {
    
    private weak var view: SelectStockReviewPresenterOutput!
    private let selectedReview: SelectedReview
//    private let reviewUseCase: ReviewUseCaseProtocol
//    private let userUseCase: UserUseCaseProtocol
    private let videoWorkUseCase: VideoWorkUseCaseProtocol
    private var casts: [CastDetail] = []

    init(view: SelectStockReviewPresenterOutput,
         selectedReview: SelectedReview,
         reviewUseCase: ReviewUseCaseProtocol,
         userUseCase: UserUseCaseProtocol,
         videoWorkuseCase: VideoWorkUseCaseProtocol) {
        self.view = view
        self.selectedReview = selectedReview
//        self.reviewUseCase = reviewUseCase
//        self.userUseCase = userUseCase
        self.videoWorkUseCase = videoWorkuseCase
    }
    
    func viewDidLoad() {
        let review = selectedReview.getReview()
        let title = makeTitle(movie: review)
        let releaseDay = makeReleaseDateText(movie: review)
        let rating = review.reviewStars ?? 3.0
        view.viewDidLoad(title: title, releaseDay: releaseDay, rating: rating, posterData: review.posterData, review: review.review, overview: review.overview)
        
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

}
