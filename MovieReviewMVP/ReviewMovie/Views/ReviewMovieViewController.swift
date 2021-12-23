//
//  ReviewDemoViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/06.
//

import UIKit
import Cosmos
import FirebaseUI
import GoogleMobileAds

final class ReviewMovieViewController: UIViewController {

    private var saveButton: UIBarButtonItem!
    private var stopButton: UIBarButtonItem!
    private(set) var reviewMovieOwner: ReviewMovieOwner!
    private var bannerView: GADBannerView!
        
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
        reviewMovieOwner.editButtonTapped(isEditing: isEditing,
                                          state: presenter.returnMovieReviewState())
        setupBanner()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let review = reviewMovieOwner.returnReviewText()
        let reviewScore = reviewMovieOwner.returnReviewStarScore()
        presenter.didTapUpdateButton(editing: editing, review: review, reviewScore: reviewScore)
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
extension ReviewMovieViewController {
    
    private func getReviewAndFontColor(review: String?) -> (String, UIColor) {
        if let review = review, !review.isEmpty {
            return (review, .stringColor)
        } else {
            return (ReviewTextIsEnpty().text, .placeholderColor)
        }
    }
    
    private func makeAlert(primaryKeyIsStored: Bool, movieReviewState: MovieReviewStoreState) -> UIAlertController?  {
        switch primaryKeyIsStored {
        case true:
            let storedAlert = makeStoredAlert()
            return storedAlert
            
        case false:
            switch movieReviewState {
            case .beforeStore:
                let storeLocationAlertController = makeStoreLocationAlert(presenter: presenter)
                return storeLocationAlertController
                
            case .afterStore(.reviewed):
                return nil
                
            case .afterStore(.stock):
                let storeDateAlert = makeStoreDateAlert(presenter: presenter)
                return storeDateAlert
            }
        }
    }
    
    private func makeStoredAlert() -> UIAlertController {
        let storedAlert = UIAlertController(title: nil, message: .storedAlertMessage, preferredStyle: .alert)
        storedAlert.addAction(UIAlertAction(title: .storedAlertCancelTitle, style: .cancel, handler: nil))
        
        return storedAlert
    }
    
    private func makeStoreLocationAlert(presenter: ReviewMoviePresenterInput) -> UIAlertController {
        let storeLocationAlert = UIAlertController(title: nil, message: "保存先を選択してください", preferredStyle: .actionSheet)
        storeLocationAlert.addAction(UIAlertAction(title: "ストックに保存", style: .default) { action in
            presenter.didTapStoreLocationAlert(isStoredAsReview: false)
        })
        storeLocationAlert.addAction(UIAlertAction(title: "レビューリストに保存", style: .default) { action in
            presenter.didTapStoreLocationAlert(isStoredAsReview: true)
        })
        storeLocationAlert.addAction(UIAlertAction(title: .cancelAlert, style: .cancel, handler: nil))
        
        return storeLocationAlert
    }
    
    private func makeStoreDateAlert(presenter: ReviewMoviePresenterInput) -> UIAlertController {
        let storeDateAlert = UIAlertController(title: nil, message: .storeDateAlertMessage, preferredStyle: .actionSheet)
        storeDateAlert.addAction(UIAlertAction(title: .storeDateAlertAddDateTitle, style: .default) { action in
            presenter.didTapSelectStoreDateAlert(storeDateState: .stockDate)
        })
        storeDateAlert.addAction(UIAlertAction(title: .storeDateAlertAddTodayTitle, style: .default) { action in
            presenter.didTapSelectStoreDateAlert(storeDateState: .today)
        })
        storeDateAlert.addAction(UIAlertAction(title: .cancelAlert, style: .cancel, handler: nil))

        return storeDateAlert
    }
    
}

// MARK: - ReviewMoviePresenterOutput
extension ReviewMovieViewController : ReviewMoviePresenterOutput {
    
    func displayReviewMovie(title: String, releaseDay: String, rating: Double, posterData: Data?, review: String?, overview: String?) {
        let posterImage = (posterData == nil) ? UIImage(named: "no_image") : UIImage(data: posterData!)
        let (review, fontColor) = getReviewAndFontColor(review: review)

        reviewMovieOwner.configureReviewView(posterImage: posterImage,
                                             title: title,
                                             review: review,
                                             color: fontColor,
                                             releaseDay: releaseDay,
                                             rating: rating,
                                             overView: overview)
    }
    
    func displayCastImage(casts: [CastDetail]) {
        reviewMovieOwner.configureCastsCollectionView(casts: casts)
    }

    func displayAfterStoreButtonTapped(primaryKeyIsStored: Bool, movieReviewState: MovieReviewStoreState, editing: Bool?) {
        
        if let alert = makeAlert(primaryKeyIsStored: primaryKeyIsStored, movieReviewState: movieReviewState) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                alert.popoverPresentationController?.sourceView = self.view
                alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.maxX - 40, y: view.safeAreaInsets.top, width: 0, height: 0)
            }
            present(alert, animated: true, completion: nil)
        } else {  // .afterStore(.reviewed)の時
            guard let editing = editing else { return }
            saveButton.title = editing ? .updateButtonTitle : .editButtonTitle
            reviewMovieOwner.editButtonTapped(isEditing: editing,
                                              state: movieReviewState)
        }
    }
    
    func closeReviewMovieView(movieUpdateState: MovieUpdateState) {
        dismiss(animated: true, completion: nil)
    }
        
    func displayLoggingOutAlert() {
        let loginAlert = UIAlertController.makeLoginAlert(presenter: presenter)
        present(loginAlert, animated: true, completion: nil)
    }
    
    func displayLoginView() {
        if let authUI = FUIAuth.defaultAuthUI() {
            if #available(iOS 13.0, *) {
                authUI.providers = [
                    FUIOAuth.appleAuthProvider(),
                    FUIGoogleAuth(authUI: authUI),
                    FUIOAuth.twitterAuthProvider()
                ]
            } else {
                authUI.providers = [
                    FUIGoogleAuth(authUI: authUI),
                    FUIOAuth.twitterAuthProvider()
                ]
            }
            authUI.delegate = self
            
            let authViewController = authUI.authViewController()
            self.present(authViewController, animated: true)
        }
    }
}

// MARK: - FUIAuthDelegate
extension ReviewMovieViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            print("\(user.uid)でサインインしました。emailは\(user.email ?? "")です。アカウントは\(user.displayName ?? "")")
            NotificationCenter.default.post(name: .login, object: nil)
        }
    }
}

// MARK: - GADBannerViewDelegate
extension ReviewMovieViewController : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
          bannerView.alpha = 1
        })
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
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
        
        // MARK: NavigationBarのtitleに保存日を表示
        guard let movieReviewElement = presenter.returnMovieReviewElement() else { return }
        let saveDate = movieReviewElement.create_at
        let movieReviewState = presenter.returnMovieReviewState()
        let navigationTitle = DateFormat().convertDateToStringForNavigationTitle(date: saveDate, state: movieReviewState)
        navigationItem.title = navigationTitle
    }
    
    func setupTextView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: nil, object: nil)
        reviewMovieOwner.initReviewTextView()
    }

    private func setupBanner() {
        let bannerSize = GADAdSizeBanner
        bannerView = GADBannerView(adSize: bannerSize)

        addBannerViewToView(bannerView)

        bannerView.delegate = self
        
        if let id = adUnitID(key: "banner") {
            bannerView.adUnitID = id
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            let adSize = GADAdSizeFromCGSize(CGSize(width: view.bounds.width, height: bannerSize.size.height))
            bannerView.adSize = adSize
        }
        
        func adUnitID(key: String) -> String? {
            guard let adUnitIDs = Bundle.main.object(forInfoDictionaryKey: "AdUnitIDs") as? [String: String] else {
                return nil
            }
            return adUnitIDs[key]
        }
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        [bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         bannerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         bannerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)]
            .forEach { $0.isActive = true }
    }

}
// MARK: - @objc
private extension ReviewMovieViewController {
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) { // textViewに入力がない場合とある場合の保存処理
        let reviewScore = reviewMovieOwner.returnReviewStarScore()
        let review = reviewMovieOwner.returnReviewText()
            presenter.didTapUpdateButton(editing: nil,
                                         date: Date(),
                                         reviewScore: reviewScore,
                                         review: review)
    }

    
    @objc func stopButtonTapped(_ sender: UIBarButtonItem) {
            dismiss(animated: true, completion: nil)
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
