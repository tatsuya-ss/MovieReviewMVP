//
//  TMDbRequest.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/07.
//

import Foundation

struct TMDbAPI {
    
    static let key = ProcessInfo.processInfo.environment["TMDbAPIKEY"]!
    
    struct SearchRequest {
        let query: String
        let page: Int
        
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
        var poterURL: URL? {
            URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
        }
    }
    
    struct DetailsRequest {
        let id: Int
        let mediaType: String
        
        func returnDetailsURLRequest() -> URL? {
            let detailsURL = "https://api.themoviedb.org/3/\(mediaType)/\(String(id))/credits?api_key=\(TMDbAPI.key)&language=ja-JP"
            guard let encodingURLString = detailsURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let encodingURL = URL(string: encodingURLString)
            else { return nil }
            return encodingURL
        }
    }
    
    // MARK: 近日公開
    struct UpcomingRequest {
        var upcomingURL: URL? {
            let urlString = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(TMDbAPI.key)&language=ja-JA&page=1&region=JP"
            return URL(string: urlString)
        }
    }
    
    // MARK: １週間
    struct TrendingWeekRequest {
        var url: URL? {
            let urlString = "https://api.themoviedb.org/3/trending/all/week?api_key=\(TMDbAPI.key)&language=ja-JA&page=1&region=JP"
            return URL(string: urlString)
        }
    }
    
    // MARK: 公開中
    struct NowPlayingRequest {
        var url: URL? {
            let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=\(TMDbAPI.key)&language=ja-JA&page=1&region=JP"
            return URL(string: urlString)
        }
    }
    
}

// MARK: ポスターの画質指定表（TMDb公式より）
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


// MARK: person
// https://api.themoviedb.org/3/person/\(String(id))?api_key=\(TMDBPersonURL.key)&language=ja-JP
