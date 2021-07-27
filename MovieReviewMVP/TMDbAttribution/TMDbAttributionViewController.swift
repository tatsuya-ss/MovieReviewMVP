//
//  TMDbAttributionViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/25.
//

import UIKit

final class TMDbAttributionViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.image = UIImage(named: "tmdb_logo")
        setupNavigation()
    }

}

extension TMDbAttributionViewController {
    private func setupNavigation() {
        let backButton = UIBarButtonItem()
        backButton.title = .setting
        backButton.tintColor = .stringColor
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }

}
