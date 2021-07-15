//
//  StockReviewMovieManagementPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/16.
//

import Foundation

protocol StockReviewMovieManagementPresenterInput {
    var numberOfStockMovies: Int { get }
    func returnStockMovieForCell(forRow row: Int) -> MovieReviewElement
    func fetchStockMovies()
    func returnSortState() -> sortState
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState)
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func didDeleteReviewMovie(_ movieUpdateState: MovieUpdateState, indexPaths: [IndexPath])
    func didSelectRowStockCollectionView(at indexPath: IndexPath)
}

protocol StockReviewMovieManagementPresenterOutput : AnyObject {
    func sortReview()
    func changeTheDisplayDependingOnTheEditingState(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func updateStockCollectionView(movieUpdateState: MovieUpdateState, indexPath: IndexPath?)
    func displayReviewMovieView(_ movie: MovieReviewElement, afterStoreState: afterStoreState, movieUpdateState: MovieUpdateState)
}


final class StockReviewMovieManagementPresenter : StockReviewMovieManagementPresenterInput {
    
    private weak var view: StockReviewMovieManagementPresenterOutput!
    private var model: StockReviewMovieManagementModelInput
    private(set) var movieReviewStockElements: [MovieReviewElement] = []
    private var sortStateManagement: sortState = .createdDescend
    let review = Review()
    
    init(view: StockReviewMovieManagementPresenterOutput, model: StockReviewMovieManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    func returnSortState() -> sortState {
        review.returnSortState()
    }

    var numberOfStockMovies: Int {
        let reviewCount = review.returnNumberOfReviews()
        return reviewCount
    }
    
    func returnStockMovieForCell(forRow row: Int) -> MovieReviewElement {
        review.returnReviewForCell(forRow: row)
    }
    
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState) {
        review.sortReviews(sortState: sortState)
        view.sortReview()
    }
    
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        view.changeTheDisplayDependingOnTheEditingState(editing, indexPaths)
    }
    
    func didSelectRowStockCollectionView(at indexPath: IndexPath) {
        let selectStockMovie = review.returnSelectedReview(indexPath: indexPath)
        view.displayReviewMovieView(selectStockMovie, afterStoreState: .stock, movieUpdateState: .modificate)
    }
    
    func didDeleteReviewMovie(_ movieUpdateState: MovieUpdateState, indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let selectedReview = review.returnSelectedReview(indexPath: indexPath)
            model.delete(movie: selectedReview)
            review.deleteReview(row: indexPath.row)
            view.updateStockCollectionView(movieUpdateState: movieUpdateState, indexPath: indexPath)
        }
    }

    func fetchStockMovies() {
        model.fetch(isStoredAsReview: false, sortState: sortStateManagement) { result in
            switch result {
            case .success(let reviews):
                self.review.fetchReviews(reviews: reviews)
                DispatchQueue.main.async {
                    self.view.updateStockCollectionView(movieUpdateState: .initial, indexPath: nil)
                }
                print(#function,reviews)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
