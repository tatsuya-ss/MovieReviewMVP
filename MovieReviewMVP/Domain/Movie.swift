//
//  Movie.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

// 依存なしで共通で使いたいもの

struct MovieSearchResponses {
    var results: [MovieReviewElement]
}


struct MovieReviewElement {
    var title: String?
    var poster_path: String?
    var original_name: String?
    var backdrop_path: String?
    var overview: String?
    var releaseDay: String?
    var reviewStars: Double?
    var review: String?
    var create_at: Date?
}


enum SearchError : Error {
    case requestError(Error)
    case responseError
}

