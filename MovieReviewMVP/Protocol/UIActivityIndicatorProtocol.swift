//
//  UIActivityIndicatorProtocol.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/12/15.
//

import UIKit

protocol UIActivityIndicatorProtocol {
    func setupIndicator(indicator: UIActivityIndicatorView)
    func startIndicator(indicator: UIActivityIndicatorView)
    func stopIndicator(indicator: UIActivityIndicatorView)
}

extension UIActivityIndicatorProtocol where Self: UIViewController {
    
    func setupIndicator(indicator: UIActivityIndicatorView) {
        indicator.color = .white
        indicator.isHidden = true
        if #available(iOS 13.0, *) {
            indicator.style = .large
        } else {
            indicator.style = .whiteLarge
        }
    }

    func startIndicator(indicator: UIActivityIndicatorView) {
        indicator.isHidden = false
        indicator.startAnimating()
        view.alpha = 0.5
    }
    
    func stopIndicator(indicator: UIActivityIndicatorView) {
        indicator.isHidden = true
        indicator.stopAnimating()
        view.alpha = 1.0
    }

}
