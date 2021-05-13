//
//  ReviewManagementCollectionViewLayout.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/13.
//

import UIKit

// ImageViewの幅を計算して、ViewDidLoadで１回だけ使用する
struct CollectionViewLayout {
    func getImageViewSize(view: UIView) -> CGFloat {
        let safeAreaWidth = view.bounds.width - 20
        let cellWidth = (safeAreaWidth - 10) / 3
        
        return cellWidth
    }
}
