//
//  ReviewManagementModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/09.
//

import Foundation

protocol ReviewManagementModelInput {
    func deleteReviewMovie(_ index: IndexPath)
}

class ReviewManagementModel : ReviewManagementModelInput {
    func deleteReviewMovie(_ index: IndexPath) {
        let movieReviewSave = MovieReviewSave()
        movieReviewSave.deleteMovieReview(index)
    }
    
}
