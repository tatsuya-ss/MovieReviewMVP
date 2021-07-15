//
//  ReviewRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/12.
//

import Foundation

protocol ReviewRepository {
    func checkSaved(movie: MovieReviewElement, completion: @escaping (Bool) -> Void)
    func save(movie: MovieReviewElement)
    func fetch(isStoredAsReview: Bool?, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
    func delete(movie: MovieReviewElement)
    func update(movie: MovieReviewElement)
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
}
