//
//  MovieRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//

import Foundation

protocol MovieReviewRepository {
    func createMovieReview(_ movie: MovieReviewElement)
    func fetchMovieReview(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement]
    func updateMovieReview(_ movie: MovieReviewElement)
    func deleteMovieReview(_ sortState: sortState, _ id: Int)
    func sortMovieReview(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement]
//    mutating func notification(_ presenter: ReviewManagementPresenterInput)
}

