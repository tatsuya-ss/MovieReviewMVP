//
//  ReviewManagementCollectionViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//

import UIKit
import Cosmos

class ReviewManagementCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var reviewView: CosmosView!
    
    static let nib = UINib(nibName: String(describing: ReviewManagementCollectionViewCell.self), bundle: nil)

    static let identifier = String(describing: ReviewManagementCollectionViewCell.self)
    
    
    
    // MARK: configure
    func configure(movieReview: MovieReviewElement) {
        
        guard let posterPath = movieReview.poster_path,
              let posterUrl = URL(string: TMDBPosterURL(posterPath: posterPath).posterURL) else { return }
        let task = URLSession.shared.dataTask(with: posterUrl) { (data, resopnse, error) in
            guard let imageData = data else { return }

            DispatchQueue.global().async { [weak self] in
                guard let image = UIImage(data: imageData) else { return }
                DispatchQueue.main.async {
                    self?.movieImageView.image = image
                }
            }
        }
        task.resume()
        
        
        reviewView.rating = movieReview.reviewStars ?? 0.0
        reviewView.text = String(movieReview.reviewStars ?? 0.0)

    }
    
    // MARK: setup
    func setupLayout() {
        movieImageView.layoutIfNeeded()
        movieImageView.layer.cornerRadius = movieImageView.bounds.width * 0.03
    }
    
    func tapCell(state: CellSelectedState) {
        switch state {
        case .selected:
            alpha = state.imageAlpha
        case .deselected:
            alpha = state.imageAlpha
        }
    }
    
}
