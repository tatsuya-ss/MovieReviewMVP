//
//  ReviewMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMoviePresenterInput {
    
}

protocol ReviewMoviePresenterOutput : AnyObject {
    
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
}
