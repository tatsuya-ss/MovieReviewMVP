//
//  ReviewDemoViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/06.
//

import UIKit
import Cosmos
import GoogleMobileAds

class ReviewMovieViewController: UIViewController {

    private var saveButton: UIBarButtonItem!
    private var stopButton: UIBarButtonItem!
    private var isUpdate: Bool = false
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
        let bannerSize = kGADAdSizeBanner
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
    
    func displayReviewMovie(movieReviewState: MovieReviewStoreState, _ movieReviewElement: MovieReviewElement) {
        reviewMovieOwner.configureReviewView(movieReviewState: movieReviewState, movie: movieReviewElement)
    }
    
    func displayCastImage(credits: Credits) {
        reviewMovieOwner.configureCastsCollectionView(credits: credits)
    }

    func displayAfterStoreButtonTapped(_ primaryKeyIsStored: Bool, _ movieReviewState: MovieReviewStoreState, editing: Bool?) {
        
        if let alert = UIAlertController.makeAlert(primaryKeyIsStored, movieReviewState: movieReviewState, presenter: presenter) {
            present(alert, animated: true, completion: nil)
        } else {  // .afterStore(.reviewed)の時
            guard let editing = editing else { return }
            if editing {
                saveButton.title = .updateButtonTitle
            } else {
                saveButton.title = .editButtonTitle
                isUpdate = true
            }
//            editing ? (saveButton.title = .updateButtonTitle) : (saveButton.title = .editButtonTitle)
            reviewMovieOwner.editButtonTapped(isEditing: editing,
                                              state: movieReviewState)
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
