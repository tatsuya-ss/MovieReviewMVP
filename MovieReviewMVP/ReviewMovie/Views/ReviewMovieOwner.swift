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
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var blackFilterView: UIView!
    
    var crewCastColumnLayout: UICollectionViewFlowLayout!
    var keyboardHeight: CGFloat?
    var casts: [CastDetail] = []

    var reviewMovieView: UIView!
    
    override init() {
        super.init()
        setNib()
        setReviwStars()
        setOverView()
        setImageView()
        setReviewText()
        setCollectionView()
        setupBlackFilter()
    }
    
    // MARK: - setup
    private func setNib() {
        reviewMovieView = UINib(nibName: .reviewMovieNibName, bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private func setReviwStars() {
        reviewStarView.didTouchCosmos = { review in
            self.reviewStarView.text = String(review)
        }
        reviewStarView.settings.fillMode = .half
        reviewStarView.isUserInteractionEnabled = true
    }

    private func setOverView() {
        overviewTextView.isEditable = false
        overviewTextView.isSelectable = false
    }
    
    private func setImageView() {
        movieImageView.layer.cornerRadius = movieImageView.bounds.width * 0.04
    }
    
    private func setReviewText() {
        reviewTextView.delegate = self
    }
    
    private func setCollectionView() {
        collectionView.dataSource = self
        crewCastColumnLayout = CrewCastColumnFlowLayout()
        collectionView.collectionViewLayout = crewCastColumnLayout
        collectionView.register(CrewCastCollectionViewCell.nib, forCellWithReuseIdentifier: CrewCastCollectionViewCell.identifier)
    }
    
    private func setupBlackFilter() {
        blackFilterView.alpha = 0.7
    }
    
    // MARK: - ViewControllerから呼ばれるメソッド
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
    
    func editButtonTapped(isEditing: Bool, state: MovieReviewStoreState) {
        guard case .afterStore(.reviewed) = state else { return }
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
    
    func configureReviewView(posterImage: UIImage?,
                             title: String,
                             review: String,
                             color: UIColor,
                             releaseDay: String,
                             rating: Double,
                             overView: String?) {
        movieImageView.image = posterImage
        backgroundImageView.image = posterImage
        titleLabel.text = title
        reviewTextView.text = review
        reviewTextView.textColor = color
        releaseDateLabel.text = releaseDay
        overviewTextView.text = overView
        reviewStarView.rating = rating
        reviewStarView.text = String(rating)
    }
    
    func configureCastsCollectionView(casts: [CastDetail]) {
        self.casts = casts
        collectionView.reloadData()
    }
    
}

// MARK: - UITextViewDelegate
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

// MARK: - DataSource
extension ReviewMovieOwner : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return casts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CrewCastCollectionViewCell.identifier, for: indexPath) as! CrewCastCollectionViewCell
        let posterImage = casts[indexPath.item].posterData == nil ? UIImage(named: "user_icon") : UIImage(data: casts[indexPath.item].posterData!)
        let castName = casts[indexPath.item].name
        cell.configure(posterImage: posterImage, castName: castName)
        
        return cell
    }
}

