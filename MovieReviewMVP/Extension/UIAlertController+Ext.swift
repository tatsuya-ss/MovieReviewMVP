//
//  UIAlertController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/23.
//

import UIKit

extension UIAlertController {
    
    class func makeAlert(_ primaryKeyIsStored: Bool, movieReviewState: MovieReviewStoreState, presenter: ReviewMoviePresenterInput) -> UIAlertController? {
        switch primaryKeyIsStored {
        case true:
            let storedAlert = makeStoredAlert()
            return storedAlert
            
        case false:
            switch movieReviewState {
            case .beforeStore:
                let storeLocationAlertController = makeStoreLocationAlert(presenter: presenter)
                return storeLocationAlertController
                
            case .afterStore(.reviewed):
                return nil
                
            case .afterStore(.stock):
                let storeDateAlert = makeStoreDateAlert(presenter: presenter)
                return storeDateAlert
            }
        }
    }
    
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
    
    // MARK: レビューの並び替えアクションシート（iOS13）
    class func makeSortAlertForReviewManagement(presenter: ReviewManagementPresenterInput) -> UIAlertController {
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
    
    class func makeLoginAlert(presenter: ReviewMoviePresenterInput) -> UIAlertController {
        let loginAlert = UIAlertController(title: "ログインしますか？", message: "ログインすることで保存機能を利用できます", preferredStyle: .alert)
        loginAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        loginAlert.addAction(UIAlertAction(title: "ログイン", style: .default, handler: { _ in
            presenter.didSelectLogin()
        }))
        
        return loginAlert
    }
}

extension UIAlertController {
    class func makeStoredAlert() -> UIAlertController {
        let storedAlert = UIAlertController(title: nil, message: .storedAlertMessage, preferredStyle: .alert)
        storedAlert.addAction(UIAlertAction(title: .storedAlertCancelTitle, style: .cancel, handler: nil))
        
        return storedAlert
    }
    
    class func makeStoreLocationAlert(presenter: ReviewMoviePresenterInput) -> UIAlertController {
        let storeLocationAlert = UIAlertController(title: nil, message: .storeLocationAlertMessage, preferredStyle: .actionSheet)
        storeLocationAlert.addAction(UIAlertAction(title: .storeLocationAlertStockTitle, style: .default) { action in
            presenter.didTapStoreLocationAlert(isStoredAsReview: false)
        })
        storeLocationAlert.addAction(UIAlertAction(title: .storeLocationAlertReviewTitle, style: .default) { action in
            presenter.didTapStoreLocationAlert(isStoredAsReview: true)
        })
        storeLocationAlert.addAction(UIAlertAction(title: .cancelAlert, style: .cancel, handler: nil))
        
        return storeLocationAlert
    }
    
    class func makeStoreDateAlert(presenter: ReviewMoviePresenterInput) -> UIAlertController {
        let storeDateAlert = UIAlertController(title: nil, message: .storeDateAlertMessage, preferredStyle: .actionSheet)
        storeDateAlert.addAction(UIAlertAction(title: .storeDateAlertAddDateTitle, style: .default) { action in
            presenter.didTapSelectStoreDateAlert(storeDateState: .stockDate)
        })
        storeDateAlert.addAction(UIAlertAction(title: .storeDateAlertAddTodayTitle, style: .default) { action in
            presenter.didTapSelectStoreDateAlert(storeDateState: .today)
        })
        storeDateAlert.addAction(UIAlertAction(title: .cancelAlert, style: .cancel, handler: nil))

        return storeDateAlert
    }

}
