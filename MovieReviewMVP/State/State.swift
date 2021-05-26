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
    case created
    case title
    case reviewStar
        
    
    var keyPath: String {
        switch self {
        case .created:
            return "created_at"
        case .title:
            return "title"
        case .reviewStar:
            return "reviewStars"
        }
    }
    
    var title: String {
        switch self {
        case .created:
            return "作成日順"
        case .title:
            return "タイトル順"
        case .reviewStar:
            return "評価順"
        }
    }
}
