//
//  State.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/13.
//

import Foundation
import UIKit

enum FetchMovieState {
    case search(refreshState)
    case upcoming
    
    var displayLabelText: String {
        switch self {
        case .search:
            return .searchLabelTitle
        case .upcoming:
            return .upcomingLabelTitle
        }
    }
}

enum refreshState {
    case initial
    case refresh
}

enum MovieUpdateState {
    case initial
    case delete
    case insert
    case modificate
}

enum MovieReviewStoreState {
    case beforeStore
    case afterStore(afterStoreState)
    
}
enum afterStoreState {
    case reviewed
    case stock
}


enum CellSelectedState {
    case selected
    case deselected
    
    var imageAlpha: CGFloat {
        switch self {
        case .selected:
            return 0.5
        case .deselected:
            return 1
        }
    }
}

enum sortState {
    case createdAscend
    case createdDescend
    case reviewStarAscend
    case reviewStarDescend
        
    var ascending: Bool {
        switch self {
        case .createdAscend:
            return false
        case .createdDescend:
            return true
        case .reviewStarAscend:
            return false
        case .reviewStarDescend:
            return true
        }
    }
    
    var keyPath: String {
        switch self {
        case .createdAscend:
            return .createdKeyPath
        case .createdDescend:
            return .createdKeyPath
        case .reviewStarAscend:
            return .reviewStarKeyPath
        case .reviewStarDescend:
            return .reviewStarKeyPath
        }
    }
    
    var title: String {
        switch self {
        case .createdAscend:
            return .createdAscendTitle
        case .createdDescend:
            return .createdDescendTitle
        case .reviewStarAscend:
            return .reviewStarAscendTitle
        case .reviewStarDescend:
            return .reviewStarDescendTitle
        }
    }
    
    var buttonTitle: String {
        title + .sortMark
    }
    // ⌄ ⋁ ▼
}

enum storeDateState {
    case stockDate
    case today
}

