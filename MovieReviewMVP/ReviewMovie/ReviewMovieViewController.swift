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
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if case .afterStore(.reviewed) = presenter.returnMovieReviewState() {
            let review = reviewMovieOwner.returnReviewText()
            let reviewStar = reviewMovieOwner.returnReviewStarScore()
            print(#function, review)
            presenter.didTapUpdateButton(editing: editing, date: Date(), reviewScore: reviewStar, review: review)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reviewMovieOwner.reviewMovieView.frame = view.frame
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reviewMovieOwner.reviewTextResignFirstResponder()
    }

}

// MARK: - setup
private extension ReviewMovieViewController {

    func setNavigationController() {
        // MARK: ボタンの表示内容を分ける
        switch presenter.returnMovieReviewState() {
        case .beforeStore:
            saveButton = UIBarButtonItem(title: .saveButtonTitle, style: .done, target: self, action: #selector(saveButtonTapped))
            stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
            stopButton.tintColor = .white
            navigationItem.leftBarButtonItem = stopButton

        case .afterStore(.reviewed):
            saveButton = editButtonItem
            saveButton.title = .editButtonTitle
            stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
            stopButton.tintColor = .white
            navigationItem.leftBarButtonItem = stopButton

        case .afterStore(.stock):
            let backButton = UIBarButtonItem()
            backButton.title = .stock
            backButton.tintColor = .stringColor
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
            saveButton = UIBarButtonItem(title: .saveButtonTitle, style: .done, target: self, action: #selector(saveButtonTapped))
        }
        
        saveButton.tintColor = .white
        navigationItem.rightBarButtonItem = saveButton
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let movieReviewElement = presenter.returnMovieReviewElement()
        let saveDate = movieReviewElement.create_at
        let navigationTitle = DateFormat().convertDateToStringForNavigationTitle(date: saveDate)
        let movieReviewState = presenter.returnMovieReviewState()
        switch movieReviewState {
        case .afterStore: navigationItem.title = navigationTitle
        case .beforeStore: break
        }

    }
    
    func setupTextView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: nil, object: nil)
        reviewMovieOwner.initReviewTextView()
    }

    
}
// MARK: - @objc
private extension ReviewMovieViewController {
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) { // textViewに入力がない場合とある場合の保存処理
        let reviewScore = reviewMovieOwner.returnReviewStarScore()
        presenter.didTapUpdateButton(editing: nil,
                                     date: Date(),
                                     reviewScore: reviewScore,
                                     review: reviewMovieOwner.returnReviewText())

    }

    
    @objc func stopButtonTapped(_ sender: UIBarButtonItem) {
        switch isUpdate {
        case true:
            performSegue(withIdentifier: .segueIdentifierForSave, sender: nil)
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
        reviewMovieOwner.keyboardHeight = keyboardHeight
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight - view.safeAreaInsets.bottom, right: 0)
        reviewMovieOwner.addContentInsets(insets: insets)

    }

}


// MARK: - ReviewMoviePresenterOutput
extension ReviewMovieViewController : ReviewMoviePresenterOutput {
    
    func displayReviewMovie(movieReviewState: MovieReviewStoreState, _ movieReviewElement: MovieReviewElement, credits: Credits) {
        print(#function, movieReviewElement.review)
        reviewMovieOwner.configureReviewView(movieReviewState: movieReviewState, movie: movieReviewElement, credits: credits)
    }

    func displayAfterStoreButtonTapped(_ primaryKeyIsStored: Bool, _ movieReviewState: MovieReviewStoreState, editing: Bool?) {
        
        if let alert = UIAlertController.makeAlert(primaryKeyIsStored, movieReviewState: movieReviewState, presenter: presenter) {
            present(alert, animated: true, completion: nil)
        } else {
            isUpdate = true
            guard let editing = editing else { return }
            editing ? (saveButton.title = .updateButtonTitle) : (saveButton.title = .editButtonTitle)
            reviewMovieOwner.editButtonTapped(editing)
        }
    }
    
    func closeReviewMovieView(movieUpdateState: MovieUpdateState) {
        switch movieUpdateState {
        case .insert:
            dismiss(animated: true, completion: nil)
        case .modificate:
            performSegue(withIdentifier: .segueIdentifierForSave, sender: nil)
        default:
            break
        }
    }
}

