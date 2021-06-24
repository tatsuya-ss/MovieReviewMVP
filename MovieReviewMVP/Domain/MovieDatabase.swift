//
//  MovieDatabase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/08.
//

import RealmSwift

class RealmMyMovieInfomation: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var reviewStars: Double = 0.0
    @objc dynamic var releaseDay: String = ""
    @objc dynamic var overview: String = ""
    @objc dynamic var review: String? = nil
    @objc dynamic var movieImagePath: String = ""
    @objc dynamic var original_name: String = ""
    @objc dynamic var backdrop_path: String = ""
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var id: Int = 0
    @objc dynamic var isStoredAsReview: Bool = true
    
    override class func primaryKey() -> String? {
        .id
    }
}



