//
//  Review.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/15.
//

import Foundation

final class ReviewManagement {
    private var reviews: [MovieReviewElement] = []
    private var selectedReview: MovieReviewElement?
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
    
    func returnReview() -> MovieReviewElement? {
        selectedReview
    }
    
    func returnReviewForCell(forRow row: Int) -> MovieReviewElement {
        reviews[row]
    }

    func fetchReviews(result: [MovieReviewElement]) {
        reviews = result
    }
    
    func getReview(review: MovieReviewElement) {
        self.selectedReview = review
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
    
    func update(isSavedAsReview: Bool? = nil,
                saveDate: Date? = nil,
                score: Double? = nil,
                review: String? = nil) {
        guard var selectedReview = selectedReview else { return }
        
        if let isSavedAsReview = isSavedAsReview {
            selectedReview.isStoredAsReview = isSavedAsReview
        }
        
        if let saveDate = saveDate {
            selectedReview.create_at = saveDate
        }
        
        if let score = score {
            selectedReview.reviewStars = score
        }
        
        if let review = review {
            selectedReview.review = review
        }
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
