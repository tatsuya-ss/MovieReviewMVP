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

    
    init(view: StockReviewMovieManagementPresenterOutput, model: StockReviewMovieManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    func returnSortState() -> sortState {
        sortStateManagement
    }

    var numberOfStockMovies: Int {
        movieReviewStockElements.count
    }
    
    func returnStockMovieForCell(forRow row: Int) -> MovieReviewElement {
        movieReviewStockElements[row]
    }
    
    func fetchStockMovies() {
        model.fetch(isStoredAsReview: false, sortState: sortStateManagement) { result in
            switch result {
            case .success(let reviews):
                self.movieReviewStockElements = reviews
                DispatchQueue.main.async {
                    self.view.updateStockCollectionView(movieUpdateState: .initial, indexPath: nil)
                }
                print(#function,reviews)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState) {
        sortStateManagement = sortState
        switch sortState {
        case .createdAscend:
            movieReviewStockElements.sort { reviewA, reviewB in
                reviewA.create_at ?? Date() > reviewB.create_at ?? Date()
            }
        case .createdDescend:
            movieReviewStockElements.sort { reviewA, reviewB in
                reviewA.create_at ?? Date() < reviewB.create_at ?? Date()
            }
        case .reviewStarAscend:
            movieReviewStockElements.sort { reviewA, reviewB in
                reviewA.reviewStars ?? 0.0 > reviewB.reviewStars ?? 0.0
            }
        case .reviewStarDescend:
            movieReviewStockElements.sort { reviewA, reviewB in
                reviewA.reviewStars ?? 0.0 < reviewB.reviewStars ?? 0.0
            }
        }
        
        view.sortReview()
    }
    
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        view.changeTheDisplayDependingOnTheEditingState(editing, indexPaths)
    }
    
    func didDeleteReviewMovie(_ movieUpdateState: MovieUpdateState, indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            model.delete(movie: movieReviewStockElements[indexPath.row])
            movieReviewStockElements.remove(at: indexPath.row)
            view.updateStockCollectionView(movieUpdateState: movieUpdateState, indexPath: indexPath)
        }
        
    }
    
    func didSelectRowStockCollectionView(at indexPath: IndexPath) {
        let selectStockMovie = movieReviewStockElements[indexPath.row]
        view.displayReviewMovieView(selectStockMovie, afterStoreState: .stock, movieUpdateState: .modificate)
    }
    
}
