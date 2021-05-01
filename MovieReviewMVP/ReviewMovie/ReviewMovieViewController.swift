//
//  ReviewMovieViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import UIKit

class ReviewMovieViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var movieImageView: UIImageView!
    
    private var presenter: ReviewMoviePresenterInput!
    func inject(presenter: ReviewMoviePresenterInput) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setLayout()
    }
    
    func setLayout() {
        backgroundImageView.alpha = 0.25
        reviewTextView.layer.borderColor = UIColor.systemGray4.cgColor
        reviewTextView.layer.borderWidth = 1.0
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
