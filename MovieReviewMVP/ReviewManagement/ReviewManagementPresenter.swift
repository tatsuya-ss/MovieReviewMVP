//
//  ReviewManagementPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/09.
//

import Foundation

protocol ReviewManagementPresenterInput {
    var numberOfMovies: Int { get }
    func returnMovieReviewForCell(forRow row: Int) -> MovieReviewElement
    func didDeleteReviewMovie(_ movieUpdateState: MovieUpdateState, indexPaths: [IndexPath])
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func fetchUpdateReviewMovies(state: MovieUpdateState)
    func didSelectRowCollectionView(at indexPath: IndexPath)
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState)
    func returnSortState() -> sortState
    func returnMovieReview() -> [MovieReviewElement]
    func didLogout()
}

protocol ReviewManagementPresenterOutput: AnyObject {
    func changeTheDisplayDependingOnTheEditingState(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func updateReview(_ movieUpdateState: MovieUpdateState, index: Int?)
    func displaySelectMyReview(_ movie: MovieReviewElement, afterStoreState: afterStoreState, movieUpdateState: MovieUpdateState)
    func sortReview()
}


class ReviewManagementPresenter : ReviewManagementPresenterInput {
    
    private weak var view: ReviewManagementPresenterOutput!
    private var model: ReviewManagementModelInput
    private var movieUpdateState: MovieUpdateState = .modificate
    private let reviewManagement = ReviewManagement()

    init(view: ReviewManagementPresenterOutput, model: ReviewManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    var numberOfMovies: Int {
        let reviewCount = reviewManagement.returnNumberOfReviews()
        return reviewCount
    }
    
    func didSelectRowCollectionView(at indexPath: IndexPath) {
        let selectStockMovie = reviewManagement.returnSelectedReview(indexPath: indexPath)
        view.displaySelectMyReview(selectStockMovie, afterStoreState: .reviewed, movieUpdateState: movieUpdateState)
    }
    
    func returnSortState() -> sortState {
        reviewManagement.returnSortState()
    }
    
    func returnMovieReview() -> [MovieReviewElement] {
        reviewManagement.returnReviews()
    }
    
    func returnMovieReviewForCell(forRow row: Int) -> MovieReviewElement {
        reviewManagement.returnReviewForCell(forRow: row)
    }
    
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        view.changeTheDisplayDependingOnTheEditingState(editing, indexPaths)
    }
    
    func fetchUpdateReviewMovies(state: MovieUpdateState) {
        let sortState = reviewManagement.returnSortState()
        model.sort(isStoredAsReview: true, sortState: sortState) { result in
            switch result {
            case .success(let reviews):
                self.reviewManagement.fetchReviews(result: reviews)
                DispatchQueue.main.async {
                    self.view.updateReview(state, index: nil)
                }
                print(#function,reviews)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func didDeleteReviewMovie(_ movieUpdateState: MovieUpdateState, indexPaths: [IndexPath]) {
        // trashが押されたら最初に呼ばれる
        for indexPath in indexPaths {
            let selectedReview = reviewManagement.returnSelectedReview(indexPath: indexPath)
            model.delete(movie: selectedReview)
            reviewManagement.deleteReview(row: indexPath.row)
            view.updateReview(movieUpdateState, index: indexPath.row)
        }
    }

    
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState) {
        reviewManagement.sortReviews(sortState: sortState)
        view.sortReview()
    }
    
    func didLogout() {
        reviewManagement.logout()
        view.updateReview(.initial, index: nil)
    }
    
}
