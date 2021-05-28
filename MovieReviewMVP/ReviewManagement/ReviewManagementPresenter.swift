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
    func didDeleteReviewMovie(_ state: MovieUpdateState, indexs: [IndexPath])
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func fetchUpdateReviewMovies(_ state: MovieUpdateState)
    func didSelectRow(at: IndexPath)
    func didTapsortButton(_ sortState: sortState)
    func returnSortState() -> sortState
    func returnMovieReview() -> [MovieReviewElement]
}

protocol ReviewManagementPresenterOutput: AnyObject {
    func deselectReview(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func updateReview(_ state: MovieUpdateState, _ index: Int?)
    func displaySelectMyReview(_ movie: MovieReviewElement)
    func sortReview()
}



class ReviewManagementPresenter : ReviewManagementPresenterInput {
    func returnMovieReview() -> [MovieReviewElement] {
        movieReviewElements
    }
    
    
    private weak var view: ReviewManagementPresenterOutput!
    private var model: ReviewManagementModelInput
    
    init(view: ReviewManagementPresenterOutput, model: ReviewManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    private(set) var movieReviewElements: [MovieReviewElement] = []
    private var sortStateManagement: sortState = .createdDescend
    
    
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
    
    func fetchUpdateReviewMovies(_ state: MovieUpdateState) {
        self.movieReviewElements = model.fetchReviewMovie(sortStateManagement)
        view.updateReview(state, nil)
    }
    
    
    func didDeleteReviewMovie(_ state: MovieUpdateState, indexs: [IndexPath]) {
        // trashが押されたら最初に呼ばれる
        print("削除時のsortStateManagement → \(sortStateManagement)")
        
        for index in indexs {
            print(movieReviewElements[index.row].title)
            movieReviewElements.remove(at: index.row)
            model.deleteReviewMovie(sortStateManagement, index)
            view.updateReview(state, index.row)

        }
        

    }

    
    func didTapsortButton(_ sortState: sortState) {
        sortStateManagement = sortState
        movieReviewElements = model.sortReview(sortState)
        // print用の処理
        print("ソート後の内容")
        for movie in movieReviewElements {
            print(movie.title)
        }
        view.sortReview()
    }



}
