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
    
    func fetch(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement] {
        repository.fetchMovieReview(sortState, isStoredAsReview: isStoredAsReview)
    }
    
    func update(_ movie: MovieReviewElement) {
        repository.updateMovieReview(movie)
    }
    
    func delete(_ sortState: sortState, _ id: Int) {
        repository.deleteMovieReview(sortState, id)
    }
    
    func sort(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement] {
        repository.sortMovieReview(sortState, isStoredAsReview: isStoredAsReview)
    }
        
}
