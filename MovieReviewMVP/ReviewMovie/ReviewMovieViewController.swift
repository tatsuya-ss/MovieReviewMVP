//
//  ReviewDemoViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/06.
//

import UIKit
import Cosmos

class ReviewMovieViewController: UIViewController {

    private var saveButton: UIBarButtonItem!
    private var stopButton: UIBarButtonItem!
    
    private var reviewMovieOwner: ReviewMovieOwner!
        
    private var presenter: ReviewMoviePresenterInput!
    func inject(presenter: ReviewMoviePresenterInput) {
        self.presenter = presenter
    }
    
    override func loadView() {
        super.loadView()
        
        reviewMovieOwner = ReviewMovieOwner()
        view.addSubview(reviewMovieOwner.reviewMovieView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationController()
        presenter.viewDidLoad()
        reviewMovieOwner.reviewTextView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reviewMovieOwner.reviewMovieView.frame = view.frame
    }
}

// MARK: - setup
private extension ReviewMovieViewController {

    func setNavigationController() {
        
        // MARK: ボタンの表示内容を分ける
        switch presenter.returnMovieReviewState() {
        case .beforeStore:
            saveButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveButtonTapped))

        case .afterStore:
            saveButton = UIBarButtonItem(title: "更新", style: .done, target: self, action: #selector(saveButtonTapped))

        }
        
        saveButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = saveButton

        stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
        stopButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = stopButton
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        

    }
    
}
// MARK: - @objc
private extension ReviewMovieViewController {
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) {
        presenter.didTapSaveButton(date: Date(),
                                   reviewScore: Double(reviewMovieOwner.reviewStarView.text!) ?? 0.0,
                                   review: reviewMovieOwner.reviewTextView.text ?? "")
        dismiss(animated: true, completion: nil)
    }

    
    @objc func stopButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate
extension ReviewMovieViewController : UITextViewDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reviewMovieOwner.reviewTextView.resignFirstResponder()
    }
}

// MARK: - ReviewMoviePresenterOutput
extension ReviewMovieViewController : ReviewMoviePresenterOutput {
    
    func displayReviewMovie(movieReviewState: MovieReviewState, _ movieReviewElement: MovieReviewElement) {
        reviewMovieOwner.fetchMovieImage(movieReviewState: movieReviewState, movie: movieReviewElement)
    }
}
