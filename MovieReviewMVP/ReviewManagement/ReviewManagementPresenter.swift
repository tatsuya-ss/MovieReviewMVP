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
    func didDeleteReviewMovie(indexs: [IndexPath]?)
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func updateReviewMovies(_ state: MovieUpdateState, _ index: Int?)
    func didSelectRow(at: IndexPath)
    
}

protocol ReviewManagementPresenterOutput: AnyObject {
    func deselectItem(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func updateItem(_ state: MovieUpdateState, _ index: Int?)
    func displayMyReview(_ movie: MovieReviewElement)
}



class ReviewManagementPresenter : ReviewManagementPresenterInput {
    
    
    private weak var view: ReviewManagementPresenterOutput!
    
    private var model: ReviewManagementModelInput
    
    init(view: ReviewManagementPresenterOutput, model: ReviewManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    private(set) var movieReviewElements: [MovieReviewElement] = []
    
    var numberOfMovies: Int {
        return movieReviewElements.count
    }
    
    func updateReviewMovies(_ state: MovieUpdateState, _ index: Int?) {
        let movieUseCase = MovieUseCase()
        let movieReviewElements = movieUseCase.fetch()
        self.movieReviewElements = movieReviewElements
        view.updateItem(state, index)
    }
    
    
    func didSelectRow(at indexPath: IndexPath) {
        view.displayMyReview(movieReviewElements[indexPath.row])
    }
    
    


    
    func didDeleteReviewMovie(indexs: [IndexPath]?) {
        print(indexs!)
        if var selectedIndexPaths = indexs {
            selectedIndexPaths.sort { $0 > $1 }
            for index in selectedIndexPaths {
                model.deleteReviewMovie(index)
            }
        }
        
    }
    
    func movieReview(forRow row: Int) -> MovieReviewElement? {
        movieReviewElements[row]
    }
    
    
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?) {
            view.deselectItem(editing, indexPaths)
    }


}
