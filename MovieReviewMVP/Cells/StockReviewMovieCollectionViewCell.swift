//
//  StockReviewMovieCollectionViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/11.
//

import UIKit

class StockReviewMovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    
    static let nib = UINib(nibName: String(describing: StockReviewMovieCollectionViewCell.self), bundle: nil)
    
    static let identifier = String(describing: StockReviewMovieCollectionViewCell.self)

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
        
        setupLayout()
    }

    // MARK: setupLayout
    func setupLayout() {
        movieImageView.layoutIfNeeded()
        movieImageView.layer.cornerRadius = movieImageView.bounds.width * 0.03
        
    }


    func tapCell(state: CellSelectedState) {
        movieImageView.alpha = state.imageAlpha
//        switch state {
//        case .selected:
//            checkImageView.isHidden = false
//        case .deselected:
//            checkImageView.isHidden = true
//        }
    }

}