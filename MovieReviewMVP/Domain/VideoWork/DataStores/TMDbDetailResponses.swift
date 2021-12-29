//
//  TMDbDetailResponses.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/09.
//

import Foundation

struct TMDbCredits: Decodable {
    var cast: [TMDbCastDetail]
    var crew: [TMDbCrewDetail]
}

struct TMDbCastDetail: Decodable {
    let id: Int?
    var profilePath: String?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case profilePath = "profile_path"
        case name
    }
}

struct TMDbCrewDetail: Decodable {
    let id: Int?
    var profilePath: String?
    var job: String?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case profilePath = "profile_path"
        case job
        case name
    }
}
