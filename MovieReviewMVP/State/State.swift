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
            return "検索結果"
        case .upcoming:
            return "近日公開"
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
            return "高評価順"
        case .reviewStarDescend:
            return "低評価順"
        }
    }
    
    var buttonTitle: String {
        title + "⋁"
    }
    // ⌄ ⋁ ▼
}


enum textViewState {
    case empty
    case notEnpty(String?)
    
    var text: String? {
        switch self {
        case .empty:
            return "レビューを入力してください"
        case let .notEnpty(review):
            return review
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .empty:
            return .lightGray
        case .notEnpty:
            return .white
        }
    }
    
    func configurePlaceholder(_ textView: UITextView) {
        switch self {
        case .empty:
            textView.text = self.text
            textView.textColor = self.textColor

        case .notEnpty:
            textView.text = self.text
            textView.textColor = self.textColor
        }
    }

}

enum storeDateState {
    case stockDate
    case today
}

