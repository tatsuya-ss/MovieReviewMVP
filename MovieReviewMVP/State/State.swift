//
//  State.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/13.
//

import Foundation


enum fetchMovieState {
    case search
    case upcoming
    
    var displayLabelText: String {
        switch self {
        case .search:
            return "検索結果"
        case .upcoming:
            return "近日公開"
        }
    }
}

enum movieUpdateState {
    case initial
    case delete
    case insert
    case modificate
}
