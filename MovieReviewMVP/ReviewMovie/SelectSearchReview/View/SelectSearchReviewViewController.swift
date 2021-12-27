//
//  SelectSearchReviewViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/12/24.
//

import UIKit
import FirebaseUI
import GoogleMobileAds

final class SelectSearchReviewViewController: UIViewController {
    
    private var saveButton: UIBarButtonItem!
    private var stopButton: UIBarButtonItem!
    private var reviewMovieOwner: ReviewMovieOwner!
    private var bannerView: GADBannerView!
    
    private var presenter: SelectSearchReviewPresenterInput!
    
    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    func inject(presenter: SelectSearchReviewPresenterInput) {
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
        setupTextView()
        setupNavigation()
        setupReview()
        setupBanner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reviewMovieOwner.reviewMovieView.frame = view.frame
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reviewMovieOwner.reviewTextResignFirstResponder()
    }
    
}

// MARK: - SelectSearchReviewPresenterOutput
extension SelectSearchReviewViewController: SelectSearchReviewPresenterOutput {
    
    func viewDidLoad(title: String, releaseDay: String, rating: Double, posterData: Data?, review: String?, overview: String?) {
        let posterImage = (posterData == nil) ? UIImage(named: "no_image") : UIImage(data: posterData!)
        let (review, fontColor) = getReviewAndFontColor(review: review)
        reviewMovieOwner.configureReviewView(posterImage: posterImage, title: title, review: review, color: fontColor, releaseDay: releaseDay, rating: rating, overView: overview)
    }
    
    func showAfterSaveButtonTapped() {
        let saveLocationAlert = makeSaveLocationAlert()
        present(saveLocationAlert, animated: true, completion: nil)
    }
    
    func showSavedReviewsAlert() {
        let savedAlert = makeSavedAlert()
        present(savedAlert, animated: true , completion: nil)
    }
    
    func showLogingOutAlert() {
        let logingOutAlert = makeLoginAlert()
        present(logingOutAlert, animated: true , completion: nil)
    }
    
    func closeReviewMovieView() {
        dismiss(animated: true, completion: nil)
    }
    
    func displayCastImage(casts: [CastDetail]) {
        reviewMovieOwner.configureCastsCollectionView(casts: casts)
    }
}

// MARK: - func
extension SelectSearchReviewViewController {
    
    private func makeSaveLocationAlert() -> UIAlertController {
        let storeLocationAlert = UIAlertController(title: nil, message: "保存先を選択してください", preferredStyle: .actionSheet)
        storeLocationAlert.addAction(UIAlertAction(title: "ストックに保存", style: .default) { [weak self] action in
            self?.presenter.didTapSaveLocationAlert(isStoredAsReview: false)
        })
        storeLocationAlert.addAction(UIAlertAction(title: "レビューリストに保存", style: .default) { [weak self] action in
            self?.presenter.didTapSaveLocationAlert(isStoredAsReview: true)
        })
        storeLocationAlert.addAction(UIAlertAction(title: .cancelAlert, style: .cancel, handler: nil))
        
        return storeLocationAlert
    }
    
    private func makeSavedAlert() -> UIAlertController {
        let storedAlert = UIAlertController(title: nil, message: .storedAlertMessage, preferredStyle: .alert)
        storedAlert.addAction(UIAlertAction(title: .storedAlertCancelTitle, style: .cancel, handler: nil))
        
        return storedAlert
    }
    
    private func makeLoginAlert() -> UIAlertController {
        let loginAlert = UIAlertController(title: "ログインしますか？", message: "ログインすると保存機能を利用できます", preferredStyle: .alert)
        loginAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        loginAlert.addAction(UIAlertAction(title: "ログイン", style: .default, handler: { [weak self] _ in
            self?.showLoginView()
        }))
        
        return loginAlert
    }
    
    private func showLoginView() {
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
    
    private func getReviewAndFontColor(review: String?) -> (String, UIColor) {
        if let review = review, !review.isEmpty {
            return (review, .stringColor)
        } else {
            return (ReviewTextIsEnpty().text, .placeholderColor)
        }
    }
    
}

// MARK: - FUIAuthDelegate
extension SelectSearchReviewViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            print("\(user.uid)でサインインしました。emailは\(user.email ?? "")です。アカウントは\(user.displayName ?? "")")
            NotificationCenter.default.post(name: .login, object: nil)
        }
    }
}

// MARK: - setup
extension SelectSearchReviewViewController {
    
    private func setupReview() {
        presenter.viewDidLoad()
    }
    
    private func setupTextView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: nil, object: nil)
    }
    
    private func setupNavigation() {
        saveButton = UIBarButtonItem(title: .saveButtonTitle, style: .done, target: self, action: #selector(saveButtonTapped))
        stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
        saveButton.tintColor = .white
        stopButton.tintColor = .white
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = stopButton
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

// MARK: - objc
extension SelectSearchReviewViewController {
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) { // textViewに入力がない場合とある場合の保存処理
        let reviewScore = reviewMovieOwner.returnReviewStarScore()
        let review = reviewMovieOwner.returnReviewText()
        presenter.didTapSaveButton(review: review, reviewScore: reviewScore)
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

// MARK: - GADBannerViewDelegate
extension SelectSearchReviewViewController : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
        print("bannerViewDidReceiveAd")
    }
}
