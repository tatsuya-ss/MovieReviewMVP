//
//  ReviewUseCase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/12.
//

import Foundation

final class ReviewUseCase {
    private var repository: ReviewRepository
    
    init(repository: ReviewRepository = Firebase()) {
        self.repository = repository
    }
    
    func save(movie: MovieReviewElement) {
        repository.save(movie: movie)
    }


}
