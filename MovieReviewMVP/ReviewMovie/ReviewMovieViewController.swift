//
//  ReviewMovieViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import UIKit
import Cosmos

class ReviewMovieViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    
    private var presenter: ReviewMoviePresenterInput!
    func inject(presenter: ReviewMoviePresenterInput) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setLayout()
        setReview()
    }
    
    func setLayout() {
        backgroundImageView.alpha = 0.5
        reviewTextView.layer.borderColor = UIColor.systemGray4.cgColor
        reviewTextView.layer.borderWidth = 1.0
    }
    
    func setReview() {
        cosmosView.didTouchCosmos = { review in
            self.cosmosView.text = String(review)
        }
        cosmosView.settings.fillMode = .half
    }
}

extension ReviewMovieViewController : ReviewMoviePresenterOutput {    
    
    func displayReviewMovie(_ movieInfomation: MovieInfomation) {
        fetchMovieImage(movie: movieInfomation)
    }
    
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
                    self?.overviewTextView.text = movie.overview
                    self?.releaseDateLabel.text = movie.release_date
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
    }
}

