//
//  ReviewMovieOwner.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/14.
//

import UIKit
import Cosmos

class ReviewMovieOwner: NSObject {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reviewStarView: CosmosView!
    @IBOutlet weak var reviewTextView: UITextView!

    var reviewMovieView: UIView!
    
    override init() {
        super.init()
        
        setNib()
        setReviwStars()
        setOverView()
    }
    
    private func setNib() {
        
        reviewMovieView = UINib(nibName: "ReviewMovie", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
        
    }
    
    private func setReviwStars() {
        
        reviewStarView.didTouchCosmos = { review in
            self.reviewStarView.text = String(review)
        }
        reviewStarView.settings.fillMode = .half

    }

    private func setOverView() {
                
        overviewTextView.isEditable = false
        overviewTextView.isSelectable = false

    }

    
    // MARK: URLから画像を取得し、映画情報をViewに反映する処理
    func fetchMovieImage(movie: MovieInfomation) {
        
        guard let posperPath = movie.poster_path,
              let posterUrl = URL(string: TMDBPosterURL(posterPath: posperPath).posterURL) else { return }
        let task = URLSession.shared.dataTask(with: posterUrl) { (data, resopnse, error) in
            guard let imageData = data else { return }
            DispatchQueue.global().async { [weak self] in
                guard let image = UIImage(data: imageData) else { return }
                DispatchQueue.main.async {
                    self?.movieImageView.image = image
                    self?.backgroundImageView.image = image
                }
            }
        }
        task.resume()
        
        if movie.title == nil || movie.title == "" {
            titleLabel.text = movie.original_name
        } else if movie.title != nil {
            titleLabel.text = movie.title
        } else {
            titleLabel.text = "タイトルがありません"
        }
        overviewTextView.text = movie.overview
        releaseDateLabel.text = movie.release_date
    }

}
