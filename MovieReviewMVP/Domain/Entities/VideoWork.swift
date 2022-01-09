//
//  VideoWork.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/07.
//

import Foundation

struct VideoWork: Hashable {
    var title: String?
    var posterPath: String?
    var posterData: Data?
    var originalName: String?
    var backdropPath: String?
    var overview: String?
    var releaseDay: String?
    var reviewStars: Double?
    var review: String?
    var createAt: Date?
    let id: Int
    var isStoredAsReview: Bool?
    var mediaType: String?
    
    var uuid = UUID()
}

extension VideoWork {
    
    static func == (lhs: VideoWork, rhs: VideoWork) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
}
