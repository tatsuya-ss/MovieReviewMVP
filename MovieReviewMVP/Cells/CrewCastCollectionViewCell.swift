//
//  CrewCastCollectionViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/02.
//

import UIKit


final class CrewCastCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var crewCastImageView: UIImageView!
    
    static let nib = UINib(nibName: String(describing: CrewCastCollectionViewCell.self), bundle: nil)

    static let identifier = String(describing: CrewCastCollectionViewCell.self)
    
    func configure(cast: CastDetail) {
        guard let posterPath = cast.profile_path,
              let posterUrl = URL(string: TMDBPosterURL(posterPath: posterPath).posterURL) else { return }
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
        crewCastImageView.layer.cornerRadius = crewCastImageView.bounds.width * 0.1
    }
    
    func resetImage() {
        crewCastImageView.image = nil
    }

}
