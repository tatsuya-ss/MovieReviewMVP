//
//  DetailedSettingHeaderView.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/26.
//

import UIKit

class DetailedSettingHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var itemLabel: UILabel!
    
    static let nib = UINib(nibName: String(describing: DetailedSettingHeaderView.self), bundle: nil)
    
    static let identifier = String(describing: DetailedSettingHeaderView.self)

    func configure(item: String) {
        itemLabel.text = item
    }

}
