//
//  VideoWorksMock.swift
//  MovieReviewMVPTests
//
//  Created by 坂本龍哉 on 2022/01/12.
//

import Foundation
@testable import MovieReviewMVP

// MARK: - モック作成
extension VideoWork {
    static func mock() -> [VideoWork] {
        [
            VideoWork(title: "ナルト",
                      posterPath: nil,
                      originalName: nil,
                      backdropPath: nil,
                      overview: nil,
                      releaseDay: nil,
                      reviewStars: 4.0,
                      review: "かっこいい",
                      createAt: nil,
                      id: 100,
                      isStoredAsReview: nil,
                      mediaType: nil),
            
            VideoWork(title: "ナルト疾風伝",
                      posterPath: nil,
                      originalName: nil,
                      backdropPath: nil,
                      overview: nil,
                      releaseDay: nil,
                      reviewStars: 5.0,
                      review: "👏",
                      createAt: nil,
                      id: 200,
                      isStoredAsReview: nil,
                      mediaType: nil)
        ]
    }
}
