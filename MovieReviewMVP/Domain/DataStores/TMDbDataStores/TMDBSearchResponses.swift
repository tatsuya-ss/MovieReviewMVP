//
//  TMDBSearchResponses.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/07.
//

import Foundation

struct TMDbSearchResponses: Decodable {
    var results: [TMDbVideoWork]
    var totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case results
        case totalPages = "total_pages"
    }
    
}

struct TMDbVideoWork: Decodable {
    var title: String?
    var posterPath: String?
    var originalName: String?
    var backdropPath: String?
    var overview: String?
    var releaseDay: String?
    var reviewStars: Double?
    var review: String?
    var createAt: Date?
    var id: Int
    var isStoredAsReview: Bool?
    var mediaType: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case posterPath = "poster_path"
        case originalName = "original_name"
        case backdropPath = "backdrop_path"
        case overview
        case releaseDay
        case reviewStars
        case review
        case createAt = "create_at"
        case id
        case isStoredAsReview
        case mediaType = "media_type"
    }
    
}
