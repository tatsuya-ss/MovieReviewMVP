//
//  ReviewManagementPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/09.
//

import Foundation

protocol ReviewManagementPresenterInput {
    func returnReviewContent()
    var numberOfMovies: Int { get }
    func movieReview(forRow row: Int) -> MovieReviewElement?
    func didDeleteReviewMovie(index: IndexPath)
}

protocol ReviewManagementPresenterOutput: AnyObject {
    func updataMovieReview()
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

    func returnReviewContent() {
        let movieUseCase = MovieUseCase()
        let movieReviewElements = movieUseCase.fetch()
        self.movieReviewElements = movieReviewElements
        view.updataMovieReview()
    }
    
    func didDeleteReviewMovie(index: IndexPath) {
        model.deleteReviewMovie(index)
        returnReviewContent()
        
    }
    
    func movieReview(forRow row: Int) -> MovieReviewElement? {
        movieReviewElements[row]
    }

}
