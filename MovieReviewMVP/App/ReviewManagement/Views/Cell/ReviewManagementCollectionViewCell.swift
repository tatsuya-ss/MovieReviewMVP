//
//  ReviewManagementCollectionViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//

import UIKit
import Cosmos

final class ReviewManagementCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var reviewView: CosmosView!
    @IBOutlet private weak var checkImageView: UIImageView!
    
    static let nib = UINib(nibName: String(describing: ReviewManagementCollectionViewCell.self), bundle: nil)

    static let identifier = String(describing: ReviewManagementCollectionViewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        movieImageView.layer.cornerRadius = movieImageView.bounds.width * 0.04
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView.image = nil
        checkImageView.image = nil
    }
    
    // MARK: configure
    func configure(posterImage: UIImage?, rating: Double, cellSelectState: CellSelectedState) {
        movieImageView.image = posterImage
        reviewView.rating = rating
        reviewView.text = String(rating)
        checkImageView.image = UIImage(named: .checkImageName)
        checkImageView.isHidden = true
        [movieImageView, reviewView].forEach { $0?.alpha = cellSelectState.imageAlpha }
        checkImageView.isHidden = cellSelectState.isHidden
        tapCell(state: cellSelectState)
    }
    
    func tapCell(state: CellSelectedState) {
        switch state {
        case .selected:
            [movieImageView, reviewView].forEach { $0?.alpha = state.imageAlpha }
            checkImageView.isHidden = false
        case .deselected:
            [movieImageView, reviewView].forEach { $0?.alpha = state.imageAlpha }
            checkImageView.isHidden = true
        }
    }
    
}
