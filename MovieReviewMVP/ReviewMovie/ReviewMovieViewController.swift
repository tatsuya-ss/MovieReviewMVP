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
    private var keyboardHeight: CGFloat?
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: nil, object: nil)
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

    }

    
    @objc func stopButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
    
    func displayReviewMovie(movieReviewState: MovieReviewState, _ movieReviewElement: MovieReviewElement) {
        reviewMovieOwner.fetchMovieImage(movieReviewState: movieReviewState, movie: movieReviewElement)
    }
    
    func displayAfterStoreButtonTapped(_ primaryKeyIsStored: Bool) {
        switch primaryKeyIsStored {
        case true:
            let storedAlert = UIAlertController(title: nil, message: "既に保存されているレビューです", preferredStyle: .alert)
            storedAlert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
            self.present(storedAlert, animated: true, completion: nil)
            
        case false:
            dismiss(animated: true, completion: nil)
        }

    }
}
