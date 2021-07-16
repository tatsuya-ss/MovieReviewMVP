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
    private let reviewManagement = ReviewManagement()
    
    init(view: StockReviewMovieManagementPresenterOutput, model: StockReviewMovieManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    func returnSortState() -> sortState {
        reviewManagement.returnSortState()
    }

    var numberOfStockMovies: Int {
        let reviewCount = reviewManagement.returnNumberOfReviews()
        return reviewCount
    }
    
    func returnStockMovieForCell(forRow row: Int) -> MovieReviewElement {
        reviewManagement.returnReviewForCell(forRow: row)
    }
    
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState) {
        reviewManagement.sortReviews(sortState: sortState)
        view.sortReview()
    }
    
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        view.changeTheDisplayDependingOnTheEditingState(editing, indexPaths)
    }
    
    func didSelectRowStockCollectionView(at indexPath: IndexPath) {
        let selectStockMovie = reviewManagement.returnSelectedReview(indexPath: indexPath)
        view.displayReviewMovieView(selectStockMovie, afterStoreState: .stock, movieUpdateState: .modificate)
    }
    
    func didDeleteReviewMovie(_ movieUpdateState: MovieUpdateState, indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let selectedReview = reviewManagement.returnSelectedReview(indexPath: indexPath)
            model.delete(movie: selectedReview)
            reviewManagement.deleteReview(row: indexPath.row)
            view.updateStockCollectionView(movieUpdateState: movieUpdateState, indexPath: indexPath)
        }
    }

    func fetchStockMovies() {
        let sortState = reviewManagement.returnSortState()
        model.fetch(isStoredAsReview: false, sortState: sortState) { result in
            switch result {
            case .success(let reviews):
                self.reviewManagement.fetchReviews(result: reviews)
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
