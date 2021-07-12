//
//  ReviewRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/12.
//

import Foundation

protocol ReviewRepository {
    func save(movie: MovieReviewElement)
    func fetch(sortState: sortState, isStoredAsReview: Bool?, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
}
