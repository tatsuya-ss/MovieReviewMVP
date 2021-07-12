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
    func fetchUpdateReviewMovies(_ state: MovieUpdateState)
    func didSelectRowCollectionView(at indexPath: IndexPath)
    func didTapSortButton(_ sortState: sortState)
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
    
    init(view: ReviewManagementPresenterOutput, model: ReviewManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    private(set) var movieReviewElements: [MovieReviewElement] = []

    private var sortStateManagement: sortState = .createdDescend
    
    
    var numberOfMovies: Int {
        return movieReviewElements.count
    }
    
    func didSelectRowCollectionView(at indexPath: IndexPath) {
        let selectStockMovie = movieReviewElements[indexPath.row]
        print(#function, selectStockMovie.review)
        view.displaySelectMyReview(selectStockMovie, afterStoreState: .reviewed, movieUpdateState: movieUpdateState)
    }
    
    func returnSortState() -> sortState {
        sortStateManagement
    }
    
    func returnMovieReview() -> [MovieReviewElement] {
        movieReviewElements
    }
    
    func returnMovieReviewForCell(forRow row: Int) -> MovieReviewElement {
        movieReviewElements[row]
    }
    
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        view.changeTheDisplayDependingOnTheEditingState(editing, indexPaths)
    }
    
    func fetchUpdateReviewMovies(_ state: MovieUpdateState) {
//        self.movieReviewElements = model.fetchReviewMovie(sortStateManagement, isStoredAsReview: true)
        model.fetch(sortStateManagement, isStoredAsReview: true) { result in
            switch result {
            case .success(let reviews):
                self.movieReviewElements = reviews
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
        print("削除時のsortStateManagement → \(sortStateManagement)")
        
        for indexPath in indexPaths {
            model.deleteReviewMovie(sortStateManagement, movieReviewElements[indexPath.row].id)
            model.delete(movie: movieReviewElements[indexPath.row])
            movieReviewElements.remove(at: indexPath.row)
            view.updateReview(movieUpdateState, index: indexPath.row)
        }

    }

    
    func didTapSortButton(_ sortState: sortState) {
        sortStateManagement = sortState
        movieReviewElements = model.sortReview(sortState, isStoredAsReview: true)
        view.sortReview()
    }
    
}
