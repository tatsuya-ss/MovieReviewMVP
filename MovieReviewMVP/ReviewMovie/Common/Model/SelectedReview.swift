//
//  SelectedReview.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/16.
//

import Foundation

final class SelectedReview {
    private var selectedReview: VideoWork
    
    init(review: VideoWork) {
        selectedReview = review
    }
    
    func getReview() -> VideoWork {
        return selectedReview
    }
    
    func checkTitle() {
        if selectedReview.title == nil || selectedReview.title?.isEmpty == true {
            selectedReview.title = selectedReview.originalName
        }
    }
    
    func checkIsChanged(reviewScore: Double, review: String) -> Bool {
        var compareReview = review
        if review == .placeholderString {
            compareReview = ""
        }
        if selectedReview.reviewStars != reviewScore || selectedReview.review ?? "" != compareReview {  // 変更があるなら
            return true
        } else {  // 変更がないなら
            return false
        }
    }
    
    func update(isSavedAsReview: Bool? = nil,
                saveDate: Date? = nil,
                score: Double? = nil,
                review: String? = nil) {
        
        if let isSavedAsReview = isSavedAsReview {
            selectedReview.isStoredAsReview = isSavedAsReview
        }
        
        if let saveDate = saveDate {
            selectedReview.createAt = saveDate
        }
        
        if let score = score {
            selectedReview.reviewStars = score
        }
        
        if let review = review {
            if review.isEmpty || review == .placeholderString {
                selectedReview.review = nil
            } else {
                selectedReview.review = review
            }
        }
    }
    
}
