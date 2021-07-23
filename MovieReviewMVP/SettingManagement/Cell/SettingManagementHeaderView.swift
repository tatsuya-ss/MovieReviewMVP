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

    static let height: CGFloat = 44
    
    func configure(name: String) {
        nameLabel.text = name
        nameLabel.tintColor = .white
    }

}
