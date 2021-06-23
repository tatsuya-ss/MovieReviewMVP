//
//  UIAlertController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/23.
//

import UIKit

extension UIAlertController {
    class func makeStoredAlert() -> UIAlertController {
        let storedAlert = UIAlertController(title: nil, message: "既に保存されているレビューです", preferredStyle: .alert)
        storedAlert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
        
        return storedAlert
    }
    
    class func makeStoreLocationAlert(presenter: ReviewMoviePresenterInput) -> UIAlertController {
        let storeLocationAlert = UIAlertController(title: nil, message: "保存先を選択してください", preferredStyle: .actionSheet)
        storeLocationAlert.addAction(UIAlertAction(title: "後でレビューするに保存", style: .default) { action in
            presenter.didTapStoreLocationAlert(isStoredAsReview: false)
        })
        storeLocationAlert.addAction(UIAlertAction(title: "レビューリストに保存", style: .default) { action in
            presenter.didTapStoreLocationAlert(isStoredAsReview: true)
        })
        storeLocationAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        return storeLocationAlert
    }
    
    class func makeStoreDateAlert(presenter: ReviewMoviePresenterInput) -> UIAlertController {
        let storeDateAlert = UIAlertController(title: nil, message: "保存日を選択してください", preferredStyle: .actionSheet)
        storeDateAlert.addAction(UIAlertAction(title: "追加した日で保存", style: .default) { action in
            presenter.didTapSelectStoreDateAlert(storeDateState: .stockDate)
        })
        storeDateAlert.addAction(UIAlertAction(title: "今日の日付で保存", style: .default) { action in
            presenter.didTapSelectStoreDateAlert(storeDateState: .today)
        })
        storeDateAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))

        return storeDateAlert
    }
}
