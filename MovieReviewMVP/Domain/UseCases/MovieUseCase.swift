//
//  MovieUseCase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/13.
//

import Foundation

class MovieUseCase {
    
    private var repository: MovieReviewRepository
    
    init(repository: MovieReviewRepository = MovieDataStore()) {
        self.repository = repository
    }
    
    func create(_ movie: MovieReviewElement) {
        repository.createMovieReview(movie)
    }
    
    func fetch(_ sortState: sortState) -> [MovieReviewElement] {
        repository.fetchMovieReview(sortState)
    }
    
    func update(_ movie: MovieReviewElement) {
        repository.updateMovieReview(movie)
    }
    
    func delete(_ sortState: sortState, _ index: IndexPath) {
        repository.deleteMovieReview(sortState, index)
    }
    
    func sort(_ sortState: sortState) -> [MovieReviewElement] {
        repository.sortMovieReview(sortState)
    }
    
    // MARK: 更新通知を受け取る
    func notification(_ presenter: ReviewManagementPresenterInput) {
        repository.notification(presenter)
    }
    
}
