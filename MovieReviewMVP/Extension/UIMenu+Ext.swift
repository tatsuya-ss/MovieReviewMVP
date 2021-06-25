//
//  UIMenu+Ext.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/25.
//

import UIKit

extension UIMenu {
    class func makeSortMenuForReview(presenter: ReviewManagementPresenterInput) -> UIMenu {
        let createdDescendAction = UIAction(title: sortState.createdDescend.title, image: nil, state: .off, handler: { _ in
            presenter.didTapSortButton(.createdDescend)
        })
        
        let createdAscendAction = UIAction(title: sortState.createdAscend.title, image: nil, state: .off, handler: { _ in
            presenter.didTapSortButton(.createdAscend)
        })
        
        let reviewStarAscendAction = UIAction(title: sortState.reviewStarAscend.title, image: nil, state: .off, handler: { _ in
            presenter.didTapSortButton(.reviewStarAscend)
        })
        
        let reviewStarDescendAction = UIAction(title: sortState.reviewStarDescend.title, image: nil, state: .off, handler: { _ in
            presenter.didTapSortButton(.reviewStarDescend)
        })
        
        let menu = UIMenu(children: [createdDescendAction, createdAscendAction, reviewStarAscendAction, reviewStarDescendAction])
        
        return menu

    }
    
    class func makeSortMenuForStock(presenter: StockReviewMovieManagementPresenterInput) -> UIMenu {
        let createdDescendAction = UIAction(title: sortState.createdDescend.title, image: nil, state: .off, handler: { _ in
            presenter.didTapSortButton(.createdDescend)
        })
        
        let createdAscendAction = UIAction(title: sortState.createdAscend.title, image: nil, state: .off, handler: { _ in
            presenter.didTapSortButton(.createdAscend)
        })
        
        let reviewStarAscendAction = UIAction(title: sortState.reviewStarAscend.title, image: nil, state: .off, handler: { _ in
            presenter.didTapSortButton(.reviewStarAscend)
        })
        
        let reviewStarDescendAction = UIAction(title: sortState.reviewStarDescend.title, image: nil, state: .off, handler: { _ in
            presenter.didTapSortButton(.reviewStarDescend)
        })
        
        let menu = UIMenu(children: [createdDescendAction, createdAscendAction, reviewStarAscendAction, reviewStarDescendAction])
        
        return menu

    }

}
