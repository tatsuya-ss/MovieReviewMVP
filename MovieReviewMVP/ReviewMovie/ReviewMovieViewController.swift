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
    private var isUpdate: Bool = false
    private(set) var reviewMovieOwner: ReviewMovieOwner!
    private var keyboardHeight: CGFloat?

        
    private(set) var presenter: ReviewMoviePresenterInput!
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
        setupTextView()
        presenter.viewDidLoad()
        reviewMovieOwner.reviewTextView.delegate = self
        isEditing = false
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if case .afterStore(.reviewed) = presenter.returnMovieReviewState() {
            let review = reviewMovieOwner.reviewTextView.text
            let reviewStar = Double(reviewMovieOwner.reviewStarView.text!) ?? 0.0

            presenter.didTapUpdateButton(editing: editing, date: Date(), reviewScore: reviewStar, review: review)
        }
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
            stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
            stopButton.tintColor = .white
            navigationItem.leftBarButtonItem = stopButton

        case .afterStore(.reviewed):
            saveButton = editButtonItem
            stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
            stopButton.tintColor = .white
            navigationItem.leftBarButtonItem = stopButton

        case .afterStore(.stock):
            let backButton = UIBarButtonItem()
            backButton.title = "ストック"
            backButton.tintColor = .stringColor
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
            saveButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveButtonTapped))
        }
        
        saveButton.tintColor = .white
        navigationItem.rightBarButtonItem = saveButton
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

    }
    
    func setupTextView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: nil, object: nil)
        textViewState.empty.configurePlaceholder(reviewMovieOwner.reviewTextView)
    }
    
}
// MARK: - @objc
private extension ReviewMovieViewController {
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) { // textViewに入力がない場合とある場合の保存処理
        presenter.didTapUpdateButton(editing: nil,
                                     date: Date(),
                                     reviewScore: Double(reviewMovieOwner.reviewStarView.text!) ?? 0.0,
                                     review: reviewMovieOwner.reviewTextView.text)

    }

    
    @objc func stopButtonTapped(_ sender: UIBarButtonItem) {
        switch isUpdate {
        case true:
            performSegue(withIdentifier: "saveButtonTappedSegue", sender: nil)
            isUpdate = false
        case false:
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardSize = keyboardInfo.cgRectValue.size
        let keyboardHeight = keyboardSize.height
        self.keyboardHeight = keyboardHeight
        
        reviewMovieOwner.reviewTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight - view.safeAreaInsets.bottom, right: 0)

    }

}

// MARK: - UITextViewDelegate
extension ReviewMovieViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == textViewState.empty.textColor {
            textViewState.notEnpty(nil).configurePlaceholder(textView)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textViewState.empty.configurePlaceholder(textView)
        }
    }


    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let selectedTextRangeStart = textView.selectedTextRange?.start,
              let keyboardHeight = keyboardHeight else { return false }
        let caret = reviewMovieOwner.reviewTextView.caretRect(for: selectedTextRangeStart)
        let keyboardTopBorder = reviewMovieOwner.reviewTextView.bounds.size.height - keyboardHeight
        if caret.origin.y > keyboardTopBorder {
            reviewMovieOwner.reviewTextView.scrollRectToVisible(caret, animated: true)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reviewMovieOwner.reviewTextView.resignFirstResponder()
    }
}

// MARK: - ReviewMoviePresenterOutput
extension ReviewMovieViewController : ReviewMoviePresenterOutput {
    
    func displayReviewMovie(movieReviewState: MovieReviewStoreState, _ movieReviewElement: MovieReviewElement) {
        reviewMovieOwner.configureReviewView(movieReviewState: movieReviewState, movie: movieReviewElement)
    }

    func displayAfterStoreButtonTapped(_ primaryKeyIsStored: Bool, _ movieReviewState: MovieReviewStoreState, editing: Bool?) {
        
        if let alert = UIAlertController.makeAlert(primaryKeyIsStored, movieReviewState: movieReviewState, presenter: presenter) {
            present(alert, animated: true, completion: nil)
        } else {
            isUpdate = true
            guard let editing = editing else { return }
            editing ? (saveButton.title = "更新") : (saveButton.title = "編集")
            reviewMovieOwner.editButtonTapped(editing)
        }
    }
    
    func closeReviewMovieView(movieUpdateState: MovieUpdateState) {
        switch movieUpdateState {
        case .insert:
            dismiss(animated: true, completion: nil)
        case .modificate:
            performSegue(withIdentifier: "saveButtonTappedSegue", sender: nil)
        default:
            break
        }
    }
}

