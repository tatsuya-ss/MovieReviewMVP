//
//  DetailedSettingTableViewCell.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/26.
//

import UIKit

class DetailedSettingTableViewCell: UITableViewCell {

    static let nib = UINib(nibName: String(describing: DetailedSettingTableViewCell.self), bundle: nil)
    
    static let identifier = String(describing: DetailedSettingTableViewCell.self)
    
    func configure(item: String, infomation: String?) {
        textLabel?.text = item
        detailTextLabel?.text = infomation
    }


}
