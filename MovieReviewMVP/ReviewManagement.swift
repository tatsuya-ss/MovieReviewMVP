//
//  Review.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/15.
//

import Foundation

final class ReviewManagement {
    private var reviews: [MovieReviewElement] = []
    private var sortStateManagement: sortState = .createdDescend
    
    func returnSortState() -> sortState {
        sortStateManagement
    }
    
    func returnNumberOfReviews() -> Int {
        reviews.count
    }
    
    func returnReviews() -> [MovieReviewElement] {
        reviews
    }
    
    
    func returnReviewForCell(forRow row: Int) -> MovieReviewElement {
        reviews[row]
    }

    func fetchReviews(result: [MovieReviewElement]) {
        reviews = result
    }
    
    func deleteReview(row: Int) {
        reviews.remove(at: row)
    }
    
    func returnSelectedReview(indexPath: IndexPath) -> MovieReviewElement {
        reviews[indexPath.row]
    }
    
    func searchRefresh(result: [MovieReviewElement]) {
        reviews.append(contentsOf: result)
    }
    
    func logout() {
        reviews.removeAll()
    }
    
    func sortReviews(sortState: sortState) {
        sortStateManagement = sortState
        switch sortState {
        case .createdAscend:
            reviews.sort { $0.create_at ?? Date() > $1.create_at ?? Date() }
        case .createdDescend:
            reviews.sort { $0.create_at ?? Date() < $1.create_at ?? Date() }
        case .reviewStarAscend:
            reviews.sort { $0.reviewStars ?? 0.0 > $1.reviewStars ?? 0.0 }
        case .reviewStarDescend:
            reviews.sort { $0.reviewStars ?? 0.0 > $1.reviewStars ?? 0.0 }
        }
    }
    
}

