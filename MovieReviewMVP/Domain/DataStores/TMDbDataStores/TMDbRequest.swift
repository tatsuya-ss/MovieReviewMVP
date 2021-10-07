//
//  TMDbRequest.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/07.
//

import Foundation
import Keys

struct TMDbAPI {
    
    static let key = MovieReviewMVPKeys().tMDBApiKey
    
    struct SearchRequest {
        let query: String
        let page: String
        
        func returnSearchURL() -> URL? {
            let urlString = "https://api.themoviedb.org/3/search/multi?api_key=\(TMDbAPI.key)&language=ja-JP&page=\(page)&query=\(query)"
            // addingPercentEncodingで検索文字列を変換してる
            // 例）ナルト → %E3%83%8A%E3%83%AB%E3%83%88
            guard let encodingUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let encodedUrl = URL(string: encodingUrlString) else { return nil }
            return encodedUrl
        }
    }
    
    struct PosterRequest {
        let posterPath: String
        
        func returnPosterURL() -> String {
            "https://image.tmdb.org/t/p/w500\(posterPath)"
        }
    }
    
    struct DetailsRequest {
        let id: Int
        let mediaType: String
        
        func returnDetailsURLRequest() -> URLRequest? {
            let detailsURL = "https://api.themoviedb.org/3/\(mediaType)/\(String(id))/credits?api_key=\(TMDbAPI.key)&language=ja-JP"
            guard let encodingURLString = detailsURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let encodingURL = URL(string: encodingURLString)
            else { return nil }
            return URLRequest(url: encodingURL)
        }
    }
    
    // MARK: 近日公開
    struct UpcomingRequest {
        var upcomingURL: URL? {
            let urlString = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(TMDbAPI.key)&language=ja-JA&page=1&region=JP"
            return URL(string: urlString)
        }
    }
    
}
