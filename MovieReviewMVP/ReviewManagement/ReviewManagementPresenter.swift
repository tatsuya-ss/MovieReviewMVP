//
//  ReviewManagementPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/09.
//

import Foundation

protocol ReviewManagementPresenterInput {
    var numberOfMovies: Int { get }
    func movieReview(forRow row: Int) -> MovieReviewElement?
    func didDeleteReviewMovie(index: IndexPath)
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func updateReviewMovies(_ state: MovieUpdateState)
    func didSelectRow(at: IndexPath)
    func didTapsortButton(_ sortState: sortState)
    func returnSortState() -> sortState
}

protocol ReviewManagementPresenterOutput: AnyObject {
    func deselectReview(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func updateReview(_ state: MovieUpdateState, _ index: Int?)
    func displaySelectMyReview(_ movie: MovieReviewElement)
    func sortReview()
}



class ReviewManagementPresenter : ReviewManagementPresenterInput {
    
    private weak var view: ReviewManagementPresenterOutput!
    private var model: ReviewManagementModelInput
    
    init(view: ReviewManagementPresenterOutput, model: ReviewManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    private(set) var movieReviewElements: [MovieReviewElement] = []
    private var sortStateManagement: sortState = .createdDescend
    private var deleteIndex: IndexPath?
    
    
    var numberOfMovies: Int {
        return movieReviewElements.count
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        view.displaySelectMyReview(movieReviewElements[indexPath.row])
    }
    
    func returnSortState() -> sortState {
        sortStateManagement
    }
    
    func movieReview(forRow row: Int) -> MovieReviewElement? {
        movieReviewElements[row]
    }
    
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?) {
            view.deselectReview(editing, indexPaths)
    }
    
    func updateReviewMovies(_ state: MovieUpdateState) {
        let movieUseCase = MovieUseCase()
        self.movieReviewElements = movieUseCase.fetch(sortStateManagement)

        view.updateReview(state, deleteIndex?.row)
    }
    
    func didTapsortButton(_ sortState: sortState) {
        sortStateManagement = sortState
        movieReviewElements = model.sortReview(sortState)
        view.sortReview()
    }
    
    func didDeleteReviewMovie(index: IndexPath) {
        print("削除時のsortStateManagement → \(sortStateManagement)")
        deleteIndex = index
        model.deleteReviewMovie(sortStateManagement, index)
    }



}
