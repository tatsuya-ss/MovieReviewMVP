//
//  MovieTableViewCell.swift
//  MovieReviewMVP
//¥
//  Created by 坂本龍哉 on 2021/04/29.
//

import UIKit

final class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    static let nib = UINib(nibName: String(describing: MovieTableViewCell.self), bundle: nil)
    static let reuserIdentifier: String = .movieTableCellIdentifier
    
    override func awakeFromNib() {
        super.awakeFromNib()
        movieImageView.layer.cornerRadius = movieImageView.bounds.height * 0.1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView.image = nil
        titleLabel.text = nil
    }
    
    func configure(image: UIImage?, title: String, releaseDay: String) {
        movieImageView.image = image
        titleLabel.text = title
        releaseDateLabel.text = releaseDay
    }
}
