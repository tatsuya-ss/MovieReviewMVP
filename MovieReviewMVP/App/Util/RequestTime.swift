//
//  RequestCounter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2022/08/07.
//

import Foundation

struct RequestTime {
    private let requestLimitCountPerSecond = 40
    private let oneSecond = 1
    
    var sleepTime: Double {
        return Double(oneSecond) / Double(requestLimitCountPerSecond - 1)
    }
}
