//
//  MovieTableViewCell.swift
//  MovieReviewMVP
//¥
//  Created by 坂本龍哉 on 2021/04/29.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
        
    static let reuserIdentifier = "MovieCell"
    
    func resetCell() {
        movieImageView.image = nil
        titleLabel.text = nil
    }
    
    func configureCell(movie: MovieInfomation, height: CGFloat) {
        
        guard let posperPath = movie.poster_path,
              let posterUrl = URL(string: TMDBPosterURL(posterPath: posperPath).posterURL) else { return }
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
        
        if movie.title == nil || movie.title == "" {
            titleLabel.text = movie.original_name
        } else if movie.title != nil {
            titleLabel.text = movie.title
        } else {
            titleLabel.text = "タイトルがありません"
        }
        
        movieImageView.layer.cornerRadius = height * 0.03

    }
}
