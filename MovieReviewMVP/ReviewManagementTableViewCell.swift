//
//  ReviewManagementTableViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/09.
//

import UIKit
import Cosmos

class ReviewManagementTableViewCell: UITableViewCell {
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reviewStarView: CosmosView!
    static let reuseCellIdentifier = "reviewCell"
    
    func configure(movieReview: MovieReviewContent) {
        titleLabel.text = movieReview.title
        reviewStarView.rating = movieReview.reviewStars
        reviewStarView.text = String(movieReview.reviewStars)
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
}
