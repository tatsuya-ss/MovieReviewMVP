//
//  SettingManagementTableViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/23.
//

import UIKit

class SettingManagementTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    
    static let nib = UINib(nibName: String(describing: SettingManagementTableViewCell.self), bundle: nil)
    
    static let identifier = String(describing: SettingManagementTableViewCell.self)
    
    func configure(title: String) {
        titleLabel.text = title
        let disclosureImage = UIImage(named: "ic_navigate_next")!.withRenderingMode(.alwaysTemplate)
        let disclosureView = UIImageView(image: disclosureImage)
        disclosureView.tintColor = .white
        accessoryView = disclosureView
    }


}
