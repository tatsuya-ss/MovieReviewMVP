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
    
    func configure(cast: CastDetail) {
        if let posterPath = cast.profile_path,
           let posterUrl = URL(string: TMDBPosterURL(posterPath: posterPath).posterURL) {
            let task = URLSession.shared.dataTask(with: posterUrl) { (data, resopnse, error) in
                guard let imageData = data else { return }

                DispatchQueue.global().async { [weak self] in
                    guard let image = UIImage(data: imageData) else { return }
                    DispatchQueue.main.async {
                        self?.crewCastImageView.image = image
                    }
                }
            }
            task.resume()
        } else {
            crewCastImageView.image = UIImage(named: "user_icon")
        }
        nameLabel.text = cast.name
        layer.cornerRadius = bounds.width * 0.1
        blackView.gradient(lightColor: .yellow, darkColor: .black)
    }
    
    func resetImage() {
        crewCastImageView.image = nil
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
