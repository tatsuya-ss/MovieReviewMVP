//
//  SettingManagementHeaderView.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/23.
//

import UIKit

class SettingManagementHeaderView: UITableViewHeaderFooterView {

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    static let nib = UINib(nibName: String(describing: SettingManagementHeaderView.self), bundle: nil)
    
    static let identifier = String(describing: SettingManagementHeaderView.self)
    
    func configure(userInfomation: (String?, URL?), height: CGFloat) {
        guard let name = userInfomation.0,
              let url = userInfomation.1 else { return }
        nameLabel.text = name
        nameLabel.tintColor = .white
        fetchProfileImage(url: url)
        let imageHeight = height * 0.7
        profileImageView.layer.cornerRadius = imageHeight * 0.5
    }
}

extension SettingManagementHeaderView {
    private func fetchProfileImage(url: URL) {
        let task = URLSession.shared.dataTask(with: url) { (data, resopnse, error) in
            guard let imageData = data else { return }

            DispatchQueue.global().async { [weak self] in
                guard let image = UIImage(data: imageData) else { return }
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        }
        task.resume()
    }
}
