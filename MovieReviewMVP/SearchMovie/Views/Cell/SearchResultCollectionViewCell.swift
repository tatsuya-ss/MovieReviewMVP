//
//  SearchResultCollectionViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2022/01/08.
//

import UIKit

final class SearchResultCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        movieImageView.layer.cornerRadius = movieImageView.bounds.height * 0.05
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
