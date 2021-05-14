//
//  TMDB.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation
import Keys

// MARK: - Codable
// TMDBに依存しているもの
struct TMDBSearchResponses : Codable {
    var results: [MovieInfomation]
}

// MARK: - API
struct TMDBApi {
    static let key = MovieReviewMVPKeys().tMDBApiKey
    let searchURL: String
    init(query: String) {
        self.searchURL = "https://api.themoviedb.org/3/search/multi?api_key=\(TMDBApi.key)&language=ja-JP&page=1&query=\(query)"
    }
    
}

// MARK: - PosterURL
struct TMDBPosterURL {
    let posterURL: String
    init(posterPath: String) {
        self.posterURL = "https://image.tmdb.org/t/p/w185\(posterPath)"
    }
}

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
    
    let upcomingMovieURL = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(TMDBPopularMovieURL.key)&language=ja-JA&page=1&region=JP"
}

//enum TMDBSearchError : Error {
//    case TMDBrequestError(Error)
//    case TMDBresponseError
//}
