//
//  StockReviewMovieCollectionViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/11.
//

import UIKit

final class StockReviewMovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var checkImageView: UIImageView!
    
    static let nib = UINib(nibName: String(describing: StockReviewMovieCollectionViewCell.self), bundle: nil)
    
    static let identifier = String(describing: StockReviewMovieCollectionViewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        movieImageView.layer.cornerRadius = movieImageView.bounds.width * 0.03
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView.image = nil
        checkImageView.image = nil
    }

    func configure(posterImage: UIImage?, cellSelectState: CellSelectedState) {
        movieImageView.image = posterImage
        checkImageView.image = UIImage(named: .checkImageName)
        checkImageView.isHidden = true
        movieImageView.alpha = cellSelectState.imageAlpha
        checkImageView.isHidden = cellSelectState.isHidden
        tapCell(state: cellSelectState)
    }

    func tapCell(state: CellSelectedState) {
        switch state {
        case .selected:
            movieImageView.alpha = state.imageAlpha
            checkImageView.isHidden = false
        case .deselected:
            movieImageView.alpha = state.imageAlpha
            checkImageView.isHidden = true
        }
    }

}
