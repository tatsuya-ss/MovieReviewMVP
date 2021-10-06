//
//  SelectedReview.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/16.
//

import Foundation

final class SelectedReview {
    private var selectedReview: MovieReviewElement
    
    init(review: MovieReviewElement) {
        selectedReview = review
    }

    func returnReview() -> MovieReviewElement {
        print(#function, selectedReview)
        return selectedReview
    }
    
    func checkTitle() {
        if selectedReview.title == nil || selectedReview.title?.isEmpty == true {
            selectedReview.title = selectedReview.original_name
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
            print(#function, isSavedAsReview)
            selectedReview.isStoredAsReview = isSavedAsReview
        }
        
        if let saveDate = saveDate {
            print(#function, saveDate)
            selectedReview.create_at = saveDate
        }
        
        if let score = score {
            print(#function, score)
            selectedReview.reviewStars = score
        }
        
        if let review = review {
            print(#function, review)

            if review.isEmpty || review == .placeholderString {
                selectedReview.review = nil
            } else {
                selectedReview.review = review
            }
        }
    }

}
