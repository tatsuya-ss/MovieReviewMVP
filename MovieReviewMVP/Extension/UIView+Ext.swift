//
//  UIView+Ext.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/27.
//

import UIKit

extension UIView {
    class func setNavigationTitleLeft(title: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 26)
        
        return label
    }

}

