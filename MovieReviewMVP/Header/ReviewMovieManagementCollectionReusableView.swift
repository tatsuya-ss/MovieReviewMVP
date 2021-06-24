//
//  ReviewMovieManagementCollectionReusableView.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/11.
//

import UIKit

class ReviewMovieManagementCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    
    static let nib = UINib(nibName: String(describing: ReviewMovieManagementCollectionReusableView.self), bundle: nil)

    static let identifier = String(describing: ReviewMovieManagementCollectionReusableView.self)

    func configure() {
        titleLabel.text = .reviewTitle
    }
}
