//
//  SelectSearchReviewViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/12/24.
//

import UIKit

final class SelectSearchReviewViewController: UIViewController {
    
    private var reviewMovieOwner: ReviewMovieOwner!

    private var presenter: SelectSearchReviewPresenterInput!
    
    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    func inject(presenter: SelectSearchReviewPresenter) {
        self.presenter = presenter
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        reviewMovieOwner = ReviewMovieOwner()
        view.addSubview(reviewMovieOwner.reviewMovieView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reviewMovieOwner.reviewMovieView.frame = view.frame
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reviewMovieOwner.reviewTextResignFirstResponder()
    }
    
}

extension SelectSearchReviewViewController: SelectSearchReviewPresenterOutput {
    
}
