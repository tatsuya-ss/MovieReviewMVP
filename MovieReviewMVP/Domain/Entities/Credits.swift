//
//  Movie.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

// 依存なしで共通で使いたいもの
// MARK: - 出演者情報
struct Credits {
    var cast: [CastDetail]
    var crew: [CrewDetail]
}

struct CastDetail {
    var id: Int?
    var profilePath: String?
    var name: String?
    var posterData: Data?
}

struct CrewDetail {
    var id: Int?
    var profilePath: String?
    var job: String?
    var name: String?
}
