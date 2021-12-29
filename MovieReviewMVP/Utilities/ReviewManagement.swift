//
//  Review.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/15.
//

import Foundation

final class ReviewManagement {
    private var videoWorks: [VideoWork] = []
    private var sortStateManagement: sortState = .createdDescend

    func returnSortState() -> sortState {
        sortStateManagement
    }
    
    func returnNumberOfReviews() -> Int {
        videoWorks.count
    }
    
    func returnReviews() -> [VideoWork] {
        videoWorks
    }
    
    func returnReviewForCell(forRow row: Int) -> VideoWork {
        videoWorks[row]
    }

    func fetchReviews(state: FetchMovieState, results: [VideoWork]) {
        switch state {
        case .search(.initial), .upcoming:
            videoWorks = results
        case .search(.refresh):
            videoWorks.append(contentsOf: results)
        }
    }

    func fetchPosterData(index: Int, data: Data) {
        videoWorks[index].posterData = data
    }
    
    func deleteReview(row: Int) {
        videoWorks.remove(at: row)
    }
    
    func returnSelectedReview(indexPath: IndexPath) -> VideoWork {
        videoWorks[indexPath.row]
    }
    
    
    func logout() {
        videoWorks.removeAll()
    }
    
    func makeTitle(indexPath: IndexPath) -> String {
        if let title = videoWorks[indexPath.item].title, !title.isEmpty {
            return title
        } else if let originalName = videoWorks[indexPath.item].originalName, !originalName.isEmpty {
            return originalName
        } else {
            return .notTitle
        }
    }
    
    func makeReleaseDay(indexPath: IndexPath) -> String {
        if let releaseDay = videoWorks[indexPath.item].releaseDay {
            return "(\(releaseDay))"
        } else {
            return ""
        }
    }

    func sortReviews(sortState: sortState) {
        sortStateManagement = sortState
        switch sortState {
        case .createdAscend:
            videoWorks.sort { $0.createAt ?? Date() > $1.createAt ?? Date() }
        case .createdDescend:
            videoWorks.sort { $0.createAt ?? Date() < $1.createAt ?? Date() }
        case .reviewStarAscend:
            videoWorks.sort { $0.reviewStars ?? 0.0 > $1.reviewStars ?? 0.0 }
        case .reviewStarDescend:
            videoWorks.sort { $0.reviewStars ?? 0.0 < $1.reviewStars ?? 0.0 }
        }
    }
    
}

