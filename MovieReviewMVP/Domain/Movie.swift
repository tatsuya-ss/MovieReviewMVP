//
//  Movie.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation
import UIKit

// 依存なしで共通で使いたいもの

struct MovieSearchResponses {
    var results: [MovieInfomation]
}

struct MovieInfomation : Codable {
    var title: String?
    var poster_path: String?
    var original_name: String?
    var backdrop_path: String?
    var overview: String?
    var release_date: String?
}

enum SearchError : Error {
    case requestError(Error)
    case responseError
}

