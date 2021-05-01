//
//  ReviewMovieViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import UIKit

class ReviewMovieViewController: UIViewController {
    
    private var presenter: ReviewMoviePresenterInput!
    func inject(presenter: ReviewMoviePresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

extension ReviewMovieViewController : ReviewMoviePresenterOutput {
    
}
