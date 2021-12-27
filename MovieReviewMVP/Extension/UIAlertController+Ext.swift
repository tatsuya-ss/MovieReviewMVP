//
//  UIAlertController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/23.
//

import UIKit

extension UIAlertController {
    
    class func makeLogoutAlert(presenter: DetailedSettingPresenterInput) -> UIAlertController? {
        let logoutAlert = UIAlertController(title: "ログアウト",
                                            message: "ログアウトしますか？",
                                            preferredStyle: .alert)
        logoutAlert.addAction(UIAlertAction(title: "キャンセル",
                                            style: .cancel,
                                            handler: nil))
        logoutAlert.addAction(UIAlertAction(title: "ログアウト",
                                            style: .destructive,
                                            handler: { _ in
                                                presenter.logout()
                                            }))
        return logoutAlert
    }
    
    // MARK: ストックの並び替えアクションシート（iOS13）
    class func makeSortAlertForStockReview(presenter: StockReviewMovieManagementPresenterInput) -> UIAlertController {
        let alert = UIAlertController(title: "並び替える", message: nil, preferredStyle: .actionSheet)
        
        let createdDescendAction = UIAlertAction(title: sortState.createdDescend.title, style: .default, handler: { _ in
            presenter.didTapSortButton(isStoredAsReview: true, sortState: .createdDescend)
        })
        
        let createdAscendAction = UIAlertAction(title: sortState.createdAscend.title, style: .default, handler: { _ in
            presenter.didTapSortButton(isStoredAsReview: true, sortState: .createdAscend)
        })
        
        let reviewStarAscendAction = UIAlertAction(title: sortState.reviewStarAscend.title, style: .default, handler: { _ in
            presenter.didTapSortButton(isStoredAsReview: true, sortState: .reviewStarAscend)
        })
        
        let reviewStarDescendAction = UIAlertAction(title: sortState.reviewStarDescend.title, style: .default, handler: { _ in
            presenter.didTapSortButton(isStoredAsReview: true, sortState: .reviewStarDescend)
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        [createdDescendAction,
         createdAscendAction,
         reviewStarAscendAction,
         reviewStarDescendAction,
         cancelAction]
            .forEach { alert.addAction($0) }

        return alert
    }
}
