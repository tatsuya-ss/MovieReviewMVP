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
    let review = Review()

    init(view: ReviewManagementPresenterOutput, model: ReviewManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    var numberOfMovies: Int {
        let reviewCount = review.returnNumberOfReviews()
        return reviewCount
    }
    
    func didSelectRowCollectionView(at indexPath: IndexPath) {
        let selectStockMovie = review.returnSelectedReview(indexPath: indexPath)
        view.displaySelectMyReview(selectStockMovie, afterStoreState: .reviewed, movieUpdateState: movieUpdateState)
    }
    
    func returnSortState() -> sortState {
        review.returnSortState()
    }
    
    func returnMovieReview() -> [MovieReviewElement] {
        review.returnReviews()
    }
    
    func returnMovieReviewForCell(forRow row: Int) -> MovieReviewElement {
        review.returnReviewForCell(forRow: row)
    }
    
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        view.changeTheDisplayDependingOnTheEditingState(editing, indexPaths)
    }
    
    func fetchUpdateReviewMovies(state: MovieUpdateState) {
        let sortState = review.returnSortState()
        model.sort(isStoredAsReview: true, sortState: sortState) { result in
            switch result {
            case .success(let reviews):
                self.review.fetchReviews(reviews: reviews)
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
            let selectedReview = review.returnSelectedReview(indexPath: indexPath)
            model.delete(movie: selectedReview)
            review.deleteReview(row: indexPath.row)
            view.updateReview(movieUpdateState, index: indexPath.row)
        }
    }

    
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState) {
        review.sortReviews(sortState: sortState)
        view.sortReview()
    }
    
}
