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
    
    func fetch() -> [MovieReviewElement] {
        repository.fetchMovieReview()
    }
    
    func update(_ movie: MovieReviewElement) {
        repository.updateMovieReview(movie)
    }
    
    func delete(_ index: IndexPath) {
        repository.deleteMovieReview(index)
    }
    
    // MARK: 更新通知を受け取る
    func notification(_ presenter: ReviewManagementPresenterInput) {
        repository.notification(presenter)
    }
    
}
