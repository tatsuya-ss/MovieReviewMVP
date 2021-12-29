//
//  StockReviewMovieManagementPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/16.
//

import Foundation

protocol StockReviewMovieManagementPresenterInput {
    var numberOfStockMovies: Int { get }
    func returnStockMovieForCell(forRow row: Int) -> VideoWork
    func fetchStockMovies()
    func returnSortState() -> sortState
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState)
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func didDeleteReviewMovie(_ movieUpdateState: MovieUpdateState,
                              indexPaths: [IndexPath])
    func didSelectRowStockCollectionView(at indexPath: IndexPath)
    func didTapSortButtoniOS13()
}

protocol StockReviewMovieManagementPresenterOutput : AnyObject {
    func sortReview()
    func changeTheDisplayDependingOnTheEditingState(_ editing: Bool,
                                                    _ indexPaths: [IndexPath]?)
    func updateStockCollectionView(movieUpdateState: MovieUpdateState, indexPath: IndexPath?)
    func displayReviewMovieView(_ movie: VideoWork,
                                afterStoreState: afterStoreState,
                                movieUpdateState: MovieUpdateState)
    func displaySortAction()
}


final class StockReviewMovieManagementPresenter : StockReviewMovieManagementPresenterInput {
    
    private weak var view: StockReviewMovieManagementPresenterOutput!
    private let reviewManagement = ReviewManagement()
    private let reviewUseCase: ReviewUseCaseProtocol
    private var videoWorkuseCase: VideoWorkUseCaseProtocol

    init(view: StockReviewMovieManagementPresenterOutput,
         reviewUseCase: ReviewUseCaseProtocol,
         videoWorkuseCase: VideoWorkUseCaseProtocol) {
        self.view = view
        self.reviewUseCase = reviewUseCase
        self.videoWorkuseCase = videoWorkuseCase
    }
    
    func returnSortState() -> sortState {
        reviewManagement.returnSortState()
    }
    
    var numberOfStockMovies: Int {
        let reviewCount = reviewManagement.returnNumberOfReviews()
        return reviewCount
    }
    
    func returnStockMovieForCell(forRow row: Int) -> VideoWork {
        reviewManagement.returnReviewForCell(forRow: row)
    }
    
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState) {
        reviewManagement.sortReviews(sortState: sortState)
        view.sortReview()
    }
    
    func didTapSortButtoniOS13() {
        view.displaySortAction()
    }
    
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        view.changeTheDisplayDependingOnTheEditingState(editing, indexPaths)
    }
    
    func didSelectRowStockCollectionView(at indexPath: IndexPath) {
        let selectStockMovie = reviewManagement.returnSelectedReview(indexPath: indexPath)
        view.displayReviewMovieView(selectStockMovie, afterStoreState: .stock, movieUpdateState: .modificate)
    }
    
    func didDeleteReviewMovie(_ movieUpdateState: MovieUpdateState,
                              indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let selectedReview = reviewManagement.returnSelectedReview(indexPath: indexPath)
            reviewUseCase.delete(movie: selectedReview)
            reviewManagement.deleteReview(row: indexPath.row)
            view.updateStockCollectionView(movieUpdateState: movieUpdateState, indexPath: indexPath)
        }
    }
    
    func fetchStockMovies() {
        let sortState = reviewManagement.returnSortState()
        let dispatchGroup = DispatchGroup()

        reviewUseCase.fetch(isStoredAsReview: false, sortState: sortState) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let reviews):
                self?.reviewManagement.fetchReviews(state: .search(.initial), results: reviews)
                reviews.enumerated().forEach { videoWorks in
                    dispatchGroup.enter()
                    self?.videoWorkuseCase.fetchPosterImage(posterPath: videoWorks.element.posterPath) { result in
                        defer { dispatchGroup.leave() }
                        switch result {
                        case .failure(let error):
                            print(error)
                        case.success(let data):
                            self?.reviewManagement.fetchPosterData(index: videoWorks.offset, data: data)
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self?.view.updateStockCollectionView(movieUpdateState: .initial, indexPath: nil)
                }
            }
        }
    }
    
}
