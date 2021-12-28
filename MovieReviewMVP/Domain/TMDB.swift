//
//  TMDB.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

// TMDBに依存しているもの
// MARK: - 検索時

struct TMDBSearchResponses : Codable {
    var results: [MovieInfomation]
    var total_pages: Int
}

struct MovieInfomation : Codable {
    var title: String?
    var poster_path: String?
    var original_name: String?
    var backdrop_path: String?
    var overview: String?
    var release_date: String?
    var id: Int
    var media_type: String?
    
}
// MARK: - 出演者情報
struct TMDBCredits: Codable {
    var cast: [TMDBCastDetail]
    var crew: [TMDBCrewDetail]
}

struct TMDBCastDetail: Codable {
    var id: Int?
    var profile_path: String?
    var name: String?
}

struct TMDBCrewDetail: Codable {
    var id: Int?
    var profile_path: String?
    var job: String?
    var name: String?
}

// MARK: - 出演者の漢字の名前
struct TMDBPerson: Codable {
    var also_known_as: [String]?
}

// MARK: - BackdropURL
struct TMDBBackdropURL {
    let backdropURL: String
    init(backdropPath: String) {
        self.backdropURL = "https://image.tmdb.org/t/p/w185\(backdropPath)"
    }

}
