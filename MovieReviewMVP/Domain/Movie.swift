//
//  Movie.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

// 依存なしで共通で使いたいもの

struct MovieSearchResponses {
    var results: [MovieContents]
}

struct MovieContents : Codable {
    var title: String?
    var poster_path: String?
    var original_name: String?
}

enum SearchError : Error {
    case requestError(Error)
    case responseError
}
