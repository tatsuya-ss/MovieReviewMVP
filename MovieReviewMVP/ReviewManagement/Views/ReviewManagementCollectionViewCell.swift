//
//  ReviewManagementCollectionViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//

import UIKit
import Cosmos

class ReviewManagementCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var reviewView: CosmosView!
    @IBOutlet private weak var checkImageView: UIImageView!
    
    static let nib = UINib(nibName: String(describing: ReviewManagementCollectionViewCell.self), bundle: nil)

    static let identifier = String(describing: ReviewManagementCollectionViewCell.self)
    
    func resetMovieImage() {
        movieImageView.image = nil
    }
    
    // MARK: configure
    func configure(movieReview: MovieReviewElement, cellSelectedState: CellSelectedState) {
        
        if let posterPath = movieReview.poster_path,
           !posterPath.isEmpty,
           let posterUrl = URL(string: TMDBPosterURL(posterPath: posterPath).posterURL) {
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
        } else {
            movieImageView.image = UIImage(named: "no_image")
        }
        
        reviewView.rating = movieReview.reviewStars ?? 0.0
        reviewView.text = String(movieReview.reviewStars ?? 0.0)
        checkImageView.image = UIImage(named: .checkImageName)
        checkImageView.isHidden = true
        setupLayout()
        tapCell(state: cellSelectedState)
    }
    
    // MARK: setupLayout
    func setupLayout() {
        movieImageView.layoutIfNeeded()
        movieImageView.layer.cornerRadius = movieImageView.bounds.width * 0.04
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