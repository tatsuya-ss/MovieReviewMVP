//
//  TMDB.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation
import Keys

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


// MARK: - API
struct TMDBApi {
    static let key = MovieReviewMVPKeys().tMDBApiKey
    let searchURL: String
    init(query: String, page: String) {
        self.searchURL = "https://api.themoviedb.org/3/search/multi?api_key=\(TMDBApi.key)&language=ja-JP&page=\(page)&query=\(query)"
    }
    
}
// MARK: - 詳細情報
//enum MediaType {
//    case movie
//    case tv
//    var url: String {
//        switch self {
//        case .movie: return "movie"
//        case .tv: return "tv"
//        }
//    }
//}
struct TMDBDetailURL {
    static let key = MovieReviewMVPKeys().tMDBApiKey
    let detailURL: String
    let mediaType: String
    init(id: Int, mediaType: String) {
        self.mediaType = mediaType
        self.detailURL = "https://api.themoviedb.org/3/\(mediaType)/\(String(id))/credits?api_key=19c5f8a42705c4e7ec64271c7a4ab0d5&language=ja-JP"
    }
}

struct TMDBPersonURL {
    static let key = MovieReviewMVPKeys().tMDBApiKey
    let personURL: String
    init(id: Int) {
        self.personURL = "https://api.themoviedb.org/3/person/\(String(id))?api_key=19c5f8a42705c4e7ec64271c7a4ab0d5&language=ja-JP"
    }
}


// MARK: - PosterURL
struct TMDBPosterURL {
    let posterURL: String
    init(posterPath: String) {
//        self.posterURL = "https://image.tmdb.org/t/p/w185\(posterPath)"
        self.posterURL = "https://image.tmdb.org/t/p/w500\(posterPath)"
    }
}

//|  poster  | backdrop |  still   | profile  |   logo   |
//| :------: | :------: | :------: | :------: | :------: |
//| -------- | -------- | -------- |    w45   |    w45   |
//|    w92   | -------- |    w92   | -------- |    w92   |
//|   w154   | -------- | -------- | -------- |   w154   |
//|   w185   | -------- |   w185   |   w185   |   w185   |
//| -------- |   w300   |   w300   | -------- |   w300   |
//|   w342   | -------- | -------- | -------- | -------- |
//|   w500   | -------- | -------- | -------- |   w500   |
//| -------- | -------- | -------- |   h632   | -------- |
//|   w780   |   w780   | -------- | -------- | -------- |
//| -------- |  w1280   | -------- | -------- | -------- |
//| original | original | original | original | original |

// MARK: - BackdropURL
struct TMDBBackdropURL {
    let backdropURL: String
    init(backdropPath: String) {
        self.backdropURL = "https://image.tmdb.org/t/p/w185\(backdropPath)"
    }

}

// MARK: - PopularMovieURL
struct TMDBPopularMovieURL {
    static let key = MovieReviewMVPKeys().tMDBApiKey
    let popularMovieURL = "https://api.themoviedb.org/3/movie/popular?api_key=\(TMDBPopularMovieURL.key)&language=ja-JA&page=1"
}

// MARK: - upcoming
struct TMDBUpcomingMovieURL {
    static let key = MovieReviewMVPKeys().tMDBApiKey
    let upcomingMovieURL = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(TMDBUpcomingMovieURL.key)&language=ja-JA&page=1&region=JP"
}


//enum TMDBSearchError : Error {
//    case TMDBrequestError(Error)
//    case TMDBresponseError
//}
