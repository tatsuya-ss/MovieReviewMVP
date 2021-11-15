//
//  Review.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/15.
//

import Foundation

final class ReviewManagement {
    private var videoWorks: [MovieReviewElement] = []
    private var sortStateManagement: sortState = .createdDescend
    
    func returnSortState() -> sortState {
        sortStateManagement
    }
    
    func returnNumberOfReviews() -> Int {
        videoWorks.count
    }
    
    func returnReviews() -> [MovieReviewElement] {
        videoWorks
    }
    
    func returnReviewForCell(forRow row: Int) -> MovieReviewElement {
        videoWorks[row]
    }

    func fetchReviews(result: [MovieReviewElement]) {
        videoWorks = result
    }
    
    func fetchPosterData(index: Int, data: Data) {
        videoWorks[index].posterData = data
    }
    
    func deleteReview(row: Int) {
        videoWorks.remove(at: row)
    }
    
    func returnSelectedReview(indexPath: IndexPath) -> MovieReviewElement {
        videoWorks[indexPath.row]
    }
    
    func searchRefresh(result: [MovieReviewElement]) {
        videoWorks.append(contentsOf: result)
    }
    
    func logout() {
        videoWorks.removeAll()
    }
    
    func sortReviews(sortState: sortState) {
        sortStateManagement = sortState
        switch sortState {
        case .createdAscend:
            videoWorks.sort { $0.create_at ?? Date() > $1.create_at ?? Date() }
        case .createdDescend:
            videoWorks.sort { $0.create_at ?? Date() < $1.create_at ?? Date() }
        case .reviewStarAscend:
            videoWorks.sort { $0.reviewStars ?? 0.0 > $1.reviewStars ?? 0.0 }
        case .reviewStarDescend:
            videoWorks.sort { $0.reviewStars ?? 0.0 < $1.reviewStars ?? 0.0 }
        }
    }
    
}

