//
//  CrewCastCollectionViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/02.
//

import UIKit


final class CrewCastCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var crewCastImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var blackView: UIView!
    
    static let nib = UINib(nibName: String(describing: CrewCastCollectionViewCell.self), bundle: nil)
    static let identifier = String(describing: CrewCastCollectionViewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = bounds.width * 0.05
        blackView.gradient(lightColor: .yellow, darkColor: .black)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        crewCastImageView.image = nil
    }
    
    func configure(posterImage: UIImage?, castName: String?) {
        crewCastImageView.image = posterImage
        nameLabel.text = castName
    }
    
}

private extension UIView {
    
    func gradient(lightColor: UIColor, darkColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        gradientLayer.colors = [lightColor, darkColor]
        
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
