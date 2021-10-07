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
    var originalName: String?
    var backdropPath: String?
    var overview: String?
    var releaseDay: String?
    var reviewStars: Double?
    var review: String?
    let createAt: Date?
    let id: Int
    var isStoredAsReview: Bool?
    var mediaType: String?
}
