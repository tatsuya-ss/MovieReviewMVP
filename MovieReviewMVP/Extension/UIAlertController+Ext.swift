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
