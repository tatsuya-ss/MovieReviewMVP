//
//  SelectSearchReview.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/12/24.
//

import Foundation

protocol SelectSearchReviewPresenterInput {
    
}

protocol SelectSearchReviewPresenterOutput: AnyObject {
    
}

final class SelectSearchReviewPresenter: SelectSearchReviewPresenterInput {
    
    private weak var view: SelectSearchReviewPresenterOutput!
    
    init(view: SelectSearchReviewPresenterOutput) {
        self.view = view
    }
    
}
