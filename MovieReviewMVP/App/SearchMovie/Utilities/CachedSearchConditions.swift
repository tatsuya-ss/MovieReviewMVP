//
//  CachedSearchConditions.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/11/17.
//

import Foundation

struct CachedSearchConditions {
    var page = 1
    var cachedQuery: String?
    
    mutating func initialPage() {
        page = 1
    }
    
    mutating func countUpPage() {
        page += 1
    }
    
    mutating func cachedQuery(query: String) {
        cachedQuery = query
    }
}
