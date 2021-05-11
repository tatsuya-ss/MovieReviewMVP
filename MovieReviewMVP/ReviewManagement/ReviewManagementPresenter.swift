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
    func movieReview(forRow row: Int) -> MovieReviewContent?
    func didDeleteReviewMovie(index: IndexPath)
}

protocol ReviewManagementPresenterOutput: AnyObject {
    func updataMovieReview()
}

class ReviewManagementPresenter : ReviewManagementPresenterInput {
    
    func movieReview(forRow row: Int) -> MovieReviewContent? {
        movieReviewContent[row]
    }
    
    
    
    private weak var view: ReviewManagementPresenterOutput!
    
    private var model: ReviewManagementModelInput
    
    init(view: ReviewManagementPresenterOutput, model: ReviewManagementModelInput) {
        self.view = view
        self.model = model
    }
    private(set) var movieReviewContent: [MovieReviewContent] = []
    
    var numberOfMovies: Int {
        return movieReviewContent.count
    }

    func returnReviewContent() {
        let movieReviewSave = MovieReviewSave()
        let movieReviews = movieReviewSave.fetchMovieReview()
        movieReviewContent = movieReviews
        print(movieReviewContent)
        view.updataMovieReview()
    }
    
    func didDeleteReviewMovie(index: IndexPath) {
        model.deleteReviewMovie(index)
        returnReviewContent()
        
    }

}
