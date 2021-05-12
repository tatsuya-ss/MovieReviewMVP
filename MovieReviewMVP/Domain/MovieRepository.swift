//
//  MovieRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//

import Foundation

protocol MovieReviewRepository {
    func setMovieReview(_ movie: MovieReviewElement)
    func fetchMovieReview() -> [MovieReviewElement]
    func saveMovieReview(_ movie: MovieReviewElement)
    func deleteMovieReview(_ index: IndexPath)
}
