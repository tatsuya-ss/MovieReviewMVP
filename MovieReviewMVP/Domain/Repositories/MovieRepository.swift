//
//  MovieRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//

import Foundation

protocol MovieReviewRepository {
    func createMovieReview(_ movie: MovieReviewElement)
    func fetchMovieReview() -> [MovieReviewElement]
    func updateMovieReview(_ movie: MovieReviewElement)
    func deleteMovieReview(_ index: IndexPath)
}

struct MovieReviewElement {
    let title: String
    let reviewStars: Double
    let releaseDay: String
    let overview: String
    let review: String
    let movieImagePath: String
}
