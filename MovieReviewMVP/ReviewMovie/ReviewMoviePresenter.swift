//
//  ReviewMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMoviePresenterInput {
    func viewDidLoad()
    func didTapSaveButton(reviewScore: Double, review: String)
}

protocol ReviewMoviePresenterOutput : AnyObject {
    func displayReviewMovie(_ movieInfomation: MovieInfomation)
}

final class ReviewMoviePresenter : ReviewMoviePresenterInput {
    
    private var movieInfomation: MovieInfomation
    
    private weak var view: ReviewMoviePresenterOutput!
    private var model: ReviewMovieModelInput
    
    init(movieInfomation: MovieInfomation, view: ReviewMoviePresenterOutput, model: ReviewMovieModelInput) {
        self.movieInfomation = movieInfomation
        self.view = view
        self.model = model
    }

    func viewDidLoad() {
        self.view.displayReviewMovie(movieInfomation)
    }
    
    func didTapSaveButton(reviewScore: Double, review: String) {
        let movieReviewContent = MovieReviewElement(title: movieInfomation.title ?? "", reviewStars: reviewScore, releaseDay: movieInfomation.release_date ?? "", overview: movieInfomation.overview ?? "", review: review, movieImagePath: movieInfomation.poster_path ?? "")
        model.createMovieReview(movieReviewContent)
    }
}
