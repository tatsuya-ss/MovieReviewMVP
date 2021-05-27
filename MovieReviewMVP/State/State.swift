//
//  State.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/13.
//

import Foundation
import UIKit

enum FetchMovieState {
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

enum MovieUpdateState {
    case initial
    case delete
    case insert
    case modificate
}

enum MovieReviewState {
    case beforeStore
    case afterStore
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
            return "created_at"
        case .createdDescend:
            return "created_at"
        case .reviewStarAscend:
            return "reviewStars"
        case .reviewStarDescend:
            return "reviewStars"
        }
    }
    
    var title: String {
        switch self {
        case .createdAscend:
            return "新しい順"
        case .createdDescend:
            return "古い順"
        case .reviewStarAscend:
            return "評価が高い順"
        case .reviewStarDescend:
            return "評価が低い順"
        }
    }
    
    var buttonTitle: String {
        title + "⋁"
    }
    // ⌄ ⋁ ▼
}
