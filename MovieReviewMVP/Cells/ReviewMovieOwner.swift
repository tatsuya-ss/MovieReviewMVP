//
//  ReviewMovieOwner.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/14.
//

import UIKit
import Cosmos

class ReviewMovieOwner: NSObject {
    
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var overviewTextView: UITextView!
    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var reviewStarView: CosmosView!
    @IBOutlet private weak var reviewTextView: UITextView!
    var keyboardHeight: CGFloat?

    var reviewMovieView: UIView!
    
    override init() {
        super.init()
        setNib()
        setReviwStars()
        setOverView()
        reviewTextView.delegate = self
    }
    
    private func setNib() {
        reviewMovieView = UINib(nibName: .reviewMovieNibName, bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private func setReviwStars() {
        reviewStarView.didTouchCosmos = { review in
            self.reviewStarView.text = String(review)
        }
        reviewStarView.settings.fillMode = .half
    }

    private func setOverView() {
        overviewTextView.isEditable = false
        overviewTextView.isSelectable = false
    }
    
    func returnReviewStarScore() -> Double {
        Double(reviewStarView.text!) ?? 0.0
    }
    
    func returnReviewText() -> String {
        reviewTextView.text
    }
    
    func reviewTextResignFirstResponder() {
        reviewTextView.resignFirstResponder()
    }
    
    func addContentInsets(insets: UIEdgeInsets) {
        reviewTextView.contentInset = insets
    }
    
    func editButtonTapped(_ isEditing: Bool) {
        switch isEditing {
        case true:  // 編集モード
            reviewTextView.isEditable = true
            reviewTextView.isSelectable = true
            reviewStarView.isUserInteractionEnabled = true

        case false:
            reviewTextView.isEditable = false
            reviewTextView.isSelectable = false
            reviewStarView.isUserInteractionEnabled = false
        }
    }
    
    func initReviewTextView() {
        let reviewTextIsEnpty = ReviewTextIsEnpty()
        reviewTextView.text = reviewTextIsEnpty.text
        reviewTextView.textColor = reviewTextIsEnpty.textColor
    }
    
    func changeColorForInputTextView() {
        let reviewTextIsReviewed = ReviewTextIsReviewed()
        reviewTextView.text = reviewTextIsReviewed.text
        reviewTextView.textColor = reviewTextIsReviewed.textColor
    }
    
    func configureReviewView(movieReviewState: MovieReviewStoreState, movie: MovieReviewElement, credits: Credits) {
        fetchMovieImage(movieReviewState: movieReviewState, movie: movie)
        configureReviewImfomations(movieReviewState: movieReviewState, movie: movie, credits: credits)
    }
    
    // MARK: URLから画像を取得し、映画情報をViewに反映する処理
    private func fetchMovieImage(movieReviewState: MovieReviewStoreState, movie: MovieReviewElement) {
        guard let posperPath = movie.poster_path,
              let posterUrl = URL(string: TMDBPosterURL(posterPath: posperPath).posterURL) else { return }
        let task = URLSession.shared.dataTask(with: posterUrl) { (data, resopnse, error) in
            guard let imageData = data else { return }
            DispatchQueue.global().async { [weak self] in
                guard let image = UIImage(data: imageData) else { return }
                DispatchQueue.main.async {
                    self?.movieImageView.image = image
                    self?.backgroundImageView.image = image
                }
            }
        }
        task.resume()
    }
    
//    private func fetchCast(movie: MovieReviewElement) {
//
//
//        crewLabel.text = crew?.job
//        castLabel.text = cast[0].also_known_as?.also_known_as?[0] ?? "情報なし"
//    }
    
    // MARK: 画像以外の構成を行う処理
    private func configureReviewImfomations(movieReviewState: MovieReviewStoreState, movie: MovieReviewElement, credits: Credits) {
        returnTitleName(movie: movie, credits: credits)
        returnReviewTextState(movie: movie)
        makeReleaseDateText(movie: movie)
        overviewTextView.text = movie.overview
        if case .afterStore = movieReviewState {
            reviewStarView.rating = movie.reviewStars ?? 0
            reviewStarView.text = String(movie.reviewStars ?? 0)
        }

        
    }
    
    
    
    private func returnTitleName(movie: MovieReviewElement, credits: Credits) {
        if movie.title == nil || movie.title == "" {
            titleLabel.text = movie.original_name
        } else {
            titleLabel.text = movie.title
        }
        
    }
    
    private func returnReviewTextState(movie: MovieReviewElement) {
        if let review = movie.review {
            let reviewTextIsReviewed = ReviewTextIsReviewed()
            reviewTextView.text = review
            reviewTextView.textColor = reviewTextIsReviewed.textColor
        } else {
            let reviewTextIsEnpty = ReviewTextIsEnpty()
            reviewTextView.text = reviewTextIsEnpty.text
            reviewTextView.textColor = reviewTextIsEnpty.textColor
        }
    }
    
    private func makeReleaseDateText(movie: MovieReviewElement) {
        if movie.releaseDay == "" || movie.releaseDay == nil {
            releaseDateLabel.text = " 公開日未定"
        } else {
            releaseDateLabel.text = " " + "公開日" + " " + movie.releaseDay!
        }
    }
    
    
}

extension ReviewMovieOwner : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == ReviewTextIsEnpty().textColor {
            changeColorForInputTextView()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            initReviewTextView()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let selectedTextRangeStart = textView.selectedTextRange?.start,
              let keyboardHeight = keyboardHeight else { return false }
        let caret = reviewTextView.caretRect(for: selectedTextRangeStart)
        let keyboardTopBorder = reviewTextView.bounds.size.height - keyboardHeight
        if caret.origin.y > keyboardTopBorder {
            reviewTextView.scrollRectToVisible(caret, animated: true)
        }
        return true
    }
    
}
