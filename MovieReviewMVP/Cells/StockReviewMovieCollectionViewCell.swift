//
//  StockReviewMovieCollectionViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/11.
//

import UIKit

class StockReviewMovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var checkImageView: UIImageView!
    
    static let nib = UINib(nibName: String(describing: StockReviewMovieCollectionViewCell.self), bundle: nil)
    
    static let identifier = String(describing: StockReviewMovieCollectionViewCell.self)
    
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
        checkImageView.image = UIImage(named: .checkImageName)
        checkImageView.isHidden = true
        setupLayout()
        tapCell(state: cellSelectedState)
    }
    
    func resetImage() {
        movieImageView.image = nil
    }

    // MARK: setupLayout
    func setupLayout() {
        movieImageView.layoutIfNeeded()
        movieImageView.layer.cornerRadius = movieImageView.bounds.width * 0.03
        
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
