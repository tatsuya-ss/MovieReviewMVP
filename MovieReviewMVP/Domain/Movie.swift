//
//  Movie.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

// 依存なしで共通で使いたいもの
// MARK: - 検索時
struct MovieSearchResponses {
    var results: [MovieReviewElement]
    var total_pages: Int
}


struct MovieReviewElement {
    var title: String?
    var poster_path: String?
    var posterData: Data?
    var original_name: String?
    var backdrop_path: String?
    var overview: String?
    var releaseDay: String?
    var reviewStars: Double?
    var review: String?
    var create_at: Date?
    var id: Int
    var isStoredAsReview: Bool?
    var media_type: String?
}

// MARK: - 出演者情報
struct Credits {
    var cast: [CastDetail]
    var crew: [CrewDetail]
}

struct CastDetail {
    var id: Int?
    var profile_path: String?
    var name: String?
}

struct CrewDetail {
    var id: Int?
    var profile_path: String?
    var job: String?
    var name: String?
}

// MARK: - 出演者の漢字の名前
struct Person {
    var also_known_as: [String]?
}

struct CastPersonDetail {
    var id: Int?
    var profile_path: String?
    var also_known_as: Person?
}

enum SearchError : Error {
    case requestError(Error)
    case responseError
}

