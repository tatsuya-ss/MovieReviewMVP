//
//  ReviewTextView.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/26.
//

import UIKit

protocol ReviewTextState {
    var text: String { get }
    var textColor: UIColor { get }
}

struct ReviewTextIsEnpty : ReviewTextState {
    var text: String = .placeholderString
    var textColor: UIColor = .placeholderColor
}

struct ReviewTextIsReviewed : ReviewTextState {
    var text: String = ""
    var textColor: UIColor = .stringColor
}

