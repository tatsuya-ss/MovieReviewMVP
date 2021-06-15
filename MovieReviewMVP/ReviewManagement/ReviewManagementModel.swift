//
//  ReviewManagementModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/09.
//

import Foundation

protocol ReviewManagementModelInput {
    func deleteReviewMovie(_ sortState: sortState, _ id: Int)
    func sortReview(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement]
    func fetchReviewMovie(_ sortState: sortState, isStoredAsReview: Bool) -> [MovieReviewElement]
}

class ReviewManagementModel : ReviewManagementModelInput {
    let movieUseCase = MovieUseCase()

    func deleteReviewMovie(_ sortState: sortState, _ id: Int) {
        movieUseCase.delete(sortState, id)
    }
    
    func sortReview(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement] {
        movieUseCase.sort(sortState, isStoredAsReview: isStoredAsReview)
    }

    func fetchReviewMovie(_ sortState: sortState, isStoredAsReview: Bool) -> [MovieReviewElement] {
        movieUseCase.fetch(sortState, isStoredAsReview: isStoredAsReview)
    }
    
}
