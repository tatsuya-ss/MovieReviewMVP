//
//  SelectSavedReviewViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/12/25.
//

import UIKit
import GoogleMobileAds

final class SelectSavedReviewViewController: UIViewController {
    
    private var editButton: UIBarButtonItem!
    private var stopButton: UIBarButtonItem!
    private var reviewMovieOwner: ReviewMovieOwner!
    private var bannerView: GADBannerView!
    
    private var presenter: SelectSavedReviewPresenterInput!
    
    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func inject(presenter: SelectSavedReviewPresenterInput) {
        self.presenter = presenter
    }
    
    override func loadView() {
        super.loadView()
        reviewMovieOwner = ReviewMovieOwner()
        view.addSubview(reviewMovieOwner.reviewMovieView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        setupReview()
        setupNavigation()
        setupBanner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reviewMovieOwner.reviewMovieView.frame = view.frame
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reviewMovieOwner.reviewTextResignFirstResponder()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let review = reviewMovieOwner.returnReviewText()
        let reviewScore = reviewMovieOwner.returnReviewStarScore()
        presenter.didTapEditButton(editing: editing, review: review, reviewScore: reviewScore)
    }
    
}
// MARK: - func
extension SelectSavedReviewViewController {
    
    private func getReviewAndFontColor(review: String?) -> (String, UIColor) {
        if let review = review, !review.isEmpty {
            return (review, .stringColor)
        } else {
            return (ReviewTextIsEnpty().text, .placeholderColor)
        }
    }
    
}

// MARK: - SelectSavedReviewPresenterOutput
extension SelectSavedReviewViewController: SelectSavedReviewPresenterOutput {
    
    func viewDidLoad(title: String, releaseDay: String, rating: Double, posterData: Data?, review: String?, overview: String?) {
        let posterImage = (posterData == nil) ? UIImage(named: "no_image") : UIImage(data: posterData!)
        let (review, fontColor) = getReviewAndFontColor(review: review)
        reviewMovieOwner.configureReviewView(posterImage: posterImage, title: title, review: review, color: fontColor, releaseDay: releaseDay, rating: rating, overView: overview)
    }
    
    func displayCastImage(casts: [CastDetail]) {
        reviewMovieOwner.configureCastsCollectionView(casts: casts)
    }
    
    func displayAfterEditButtonTapped(editing: Bool) {
        editButton.title = editing ? .updateButtonTitle : .editButtonTitle
        reviewMovieOwner.editButtonTapped(isEditing: editing)
    }
    
}

// MARK: - setup
extension SelectSavedReviewViewController {
    
    private func setupReview() {
        presenter.viewDidLoad()
    }
    
    func setupTextView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: nil, object: nil)
    }
    
    private func setupNavigation() {
        editButton = editButtonItem
        editButton.title = .editButtonTitle
        stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
        stopButton.tintColor = .white
        editButton.tintColor = .white
        navigationItem.leftBarButtonItem = stopButton
        navigationItem.rightBarButtonItem = editButton
        
        // MARK: NavigationBarのtitleに保存日を表示
        guard let createdDate = presenter.createdDate else { return }
        let navigationTitle = DateFormat().convertDateToStringForNavigationTitle(date: createdDate)
        navigationItem.title = navigationTitle
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
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
extension SelectSavedReviewViewController {
    
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
extension SelectSavedReviewViewController : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
        print("bannerViewDidReceiveAd")
    }
}
