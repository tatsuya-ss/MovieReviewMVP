//
//  SelectStockReviewViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/12/25.
//

import UIKit
import GoogleMobileAds

final class SelectStockReviewViewController: UIViewController {
    
    private var saveButton: UIBarButtonItem!
    private var reviewMovieOwner: ReviewMovieOwner!
    private var bannerView: GADBannerView!
    
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
    
    private func makeSaveDateAlert() -> UIAlertController {
        let storeDateAlert = UIAlertController(title: nil, message: "保存日を選択してください", preferredStyle: .actionSheet)
        storeDateAlert.addAction(UIAlertAction(title: "追加した日付で保存", style: .default) { [weak self] action in
            self?.presenter.didTapSelectSaveDateAlert(storeDateState: .stockDate)
        })
        storeDateAlert.addAction(UIAlertAction(title: "今日の日付で保存", style: .default) { [weak self] action in
            self?.presenter.didTapSelectSaveDateAlert(storeDateState: .today)
        })
        storeDateAlert.addAction(UIAlertAction(title: .cancelAlert, style: .cancel, handler: nil))
        
        return storeDateAlert
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
    
    func showAlertAfterSaveButtonTapped() {
        let saveDateAlert = makeSaveDateAlert()
        present(saveDateAlert, animated: true, completion: nil)
    }
    
    func closeView() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - setup
extension SelectStockReviewViewController {
    
    private func setupReview() {
        presenter.viewDidLoad()
    }
    
    private func setupTextView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: nil, object: nil)
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
extension SelectStockReviewViewController {
    
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
extension SelectStockReviewViewController : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
        print("bannerViewDidReceiveAd")
    }
}
