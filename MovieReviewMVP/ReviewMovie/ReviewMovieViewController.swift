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
        case .afterStore(.reviewed):
            saveButton = UIBarButtonItem(title: "更新", style: .done, target: self, action: #selector(saveButtonTapped))
        case .afterStore(.stock):
            saveButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveButtonTapped))


        }
        
        saveButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = saveButton

        stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
        stopButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = stopButton
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        

    }
    
    func setupTextView() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: nil, object: nil)

        textViewState.empty.configurePlaceholder(reviewMovieOwner.reviewTextView)
        
    }
    
}
// MARK: - @objc
private extension ReviewMovieViewController {
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) {
        // textViewに入力がない場合とある場合の保存処理
        // ストックかレビュー済みかとか関係ないやつ
        if reviewMovieOwner.reviewTextView.text.isEmpty
            || reviewMovieOwner.reviewTextView.textColor == textViewState.empty.textColor {
            presenter.didTapSaveButton(date: Date(),
                                       reviewScore: Double(reviewMovieOwner.reviewStarView.text!) ?? 0.0,
                                       review: "")

        } else {
            presenter.didTapSaveButton(date: Date(),
                                       reviewScore: Double(reviewMovieOwner.reviewStarView.text!) ?? 0.0,
                                       review: reviewMovieOwner.reviewTextView.text ?? "")
        }

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
        reviewMovieOwner.fetchMovieImage(movieReviewState: movieReviewState, movie: movieReviewElement)
    }
    
    func displayAfterStoreButtonTapped(_ primaryKeyIsStored: Bool, _ movieReviewState: MovieReviewStoreState) {
        switch primaryKeyIsStored {
        case true:
            let storedAlert = UIAlertController(title: nil, message: "既に保存されているレビューです", preferredStyle: .alert)
            storedAlert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
            self.present(storedAlert, animated: true, completion: nil)
            
        case false:
            switch movieReviewState {
            case .beforeStore:
                let storeLocationAlert = UIAlertController(title: nil, message: "保存先を選択してください", preferredStyle: .actionSheet)
                storeLocationAlert.addAction(UIAlertAction(title: "後でレビューするに保存", style: .default, handler: { _ in
                                                            self.presenter.didTapStoreLocationAlert(isStoredAsReview: false)}))
                storeLocationAlert.addAction(UIAlertAction(title: "レビューリストに保存", style: .default, handler: { _ in
                                                            self.presenter.didTapStoreLocationAlert(isStoredAsReview: true)}))
                storeLocationAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                self.present(storeLocationAlert, animated: true, completion: nil)
                
            case .afterStore(.reviewed):
//                dismiss(animated: true, completion: nil)
                performSegue(withIdentifier: "saveButtonTappedSegue", sender: nil)
                
            case .afterStore(.stock):
                let storeDateAlert = UIAlertController(title: nil, message: "保存日を選択してください", preferredStyle: .actionSheet)
                storeDateAlert.addAction(UIAlertAction(title: "追加した日で保存", style: .default, handler: {_ in
                    // アラートの処理を書く
                    self.presenter.didTapSelectStoreDateAlert(storeDateState: .stockDate)
                }))
                storeDateAlert.addAction(UIAlertAction(title: "今日の日付で保存", style: .default, handler: {_ in
                    // アラートの処理を書く
                    self.presenter.didTapSelectStoreDateAlert(storeDateState: .today)

                }))
                storeDateAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                self.present(storeDateAlert, animated: true, completion: nil)

            }
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

