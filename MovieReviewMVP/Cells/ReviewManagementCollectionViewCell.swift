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
        reviewView.rating = movieReview.reviewStars
        reviewView.text = String(movieReview.reviewStars)
        guard let posterUrl = URL(string: TMDBPosterURL(posterPath: movieReview.movieImagePath).posterURL) else { return }
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
    }
    
    // MARK: setup
    func setupLayout(width: CGFloat) {
        movieImageView.layoutIfNeeded()
        movieImageView.layer.cornerRadius = width * 0.03
    }
    
}
