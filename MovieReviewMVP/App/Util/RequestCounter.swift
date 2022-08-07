//
//  RequestCounter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2022/08/07.
//

import Foundation

struct RequestCounter {
    private let limitRequestCountPerSecond = 15
    private(set) var currentRequestCount = 0
    
    var isLimit: Bool {
        limitRequestCountPerSecond <= currentRequestCount
    }
    
    mutating func incrementRequestCount() {
        currentRequestCount += 1
    }
    
    mutating func reset() {
        currentRequestCount = 0
    }
}
