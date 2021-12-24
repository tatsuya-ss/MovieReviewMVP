//
//  SelectStockReviewViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/12/25.
//

import UIKit

final class SelectStockReviewViewController: UIViewController {
    
    private var saveButton: UIBarButtonItem!
    private var reviewMovieOwner: ReviewMovieOwner!
    
    private var presenter: SelectStockReviewPresenterInput!
    
    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    func inject(presenter: SelectStockReviewPresenter) {
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
        setupReview()
        setupNavigation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reviewMovieOwner.reviewMovieView.frame = view.frame
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reviewMovieOwner.reviewTextResignFirstResponder()
    }
    
}

// MARK: - func
extension SelectStockReviewViewController {
    
    private func getReviewAndFontColor(review: String?) -> (String, UIColor) {
        if let review = review, !review.isEmpty {
            return (review, .stringColor)
        } else {
            return (ReviewTextIsEnpty().text, .placeholderColor)
        }
    }
    
}

// MARK: - SelectStockReviewPresenterOutput
extension SelectStockReviewViewController: SelectStockReviewPresenterOutput {
    
    func viewDidLoad(title: String, releaseDay: String, rating: Double, posterData: Data?, review: String?, overview: String?) {
        let posterImage = (posterData == nil) ? UIImage(named: "no_image") : UIImage(data: posterData!)
        let (review, fontColor) = getReviewAndFontColor(review: review)
        reviewMovieOwner.configureReviewView(posterImage: posterImage, title: title, review: review, color: fontColor, releaseDay: releaseDay, rating: rating, overView: overview)
    }
    
    func displayCastImage(casts: [CastDetail]) {
        reviewMovieOwner.configureCastsCollectionView(casts: casts)
    }
    
}

// MARK: - setup
extension SelectStockReviewViewController {
    
    private func setupReview() {
        presenter.viewDidLoad()
    }
    
    private func setupNavigation() {
        let backButton = UIBarButtonItem()
        backButton.title = .stock
        backButton.tintColor = .stringColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        saveButton = UIBarButtonItem(title: .saveButtonTitle, style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .stringColor
        navigationItem.rightBarButtonItem = saveButton
    }
    
}

// MARK: - objc
extension SelectStockReviewViewController {
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) { // textViewに入力がない場合とある場合の保存処理
        let reviewScore = reviewMovieOwner.returnReviewStarScore()
        let review = reviewMovieOwner.returnReviewText()
//        presenter.didTapSaveButton(review: review, reviewScore: reviewScore)
    }
    
    @objc func stopButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
