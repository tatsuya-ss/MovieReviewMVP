//
//  ReviewManagementCollectionViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//



import UIKit
import FirebaseUI
import GoogleMobileAds

class ReviewManagementCollectionViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var colunmFlowLayout: UICollectionViewFlowLayout!
    private var sortButton: UIBarButtonItem!
    private var editButton: UIBarButtonItem!
    private var trashButton: UIButton!
    private var stockButton: UIButton!
        
    var bannerView: GADBannerView!

    
    private(set) var presenter: ReviewManagementPresenterInput!
    func inject(presenter: ReviewManagementPresenterInput) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLogin()
        setupPresenter()
        setupNavigation()
        setupCollectionView()
        setupTrashButton()
        setupStockButton()
        setupNotification()
        setupTabBarController()
        presenter.fetchUpdateReviewMovies(state: .initial)
        isEditing = false
        setupBanner()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let indexPaths: [IndexPath]? = collectionView.indexPathsForSelectedItems
        presenter.changeEditingStateProcess(editing, indexPaths)
        
    }
    
    @IBAction func saveButtonTappedSegue(segue: UIStoryboardSegue) {
        guard let reviewMovieViewController = segue.source as? ReviewMovieViewController else { return }
        let movieUpdateState = reviewMovieViewController.presenter.returnMovieUpdateState()
        presenter.fetchUpdateReviewMovies(state: movieUpdateState)
    }
    
}

// MARK: - setup
private extension ReviewManagementCollectionViewController {
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        [bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         bannerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         bannerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
//         bannerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ].forEach { $0.isActive = true }
    }
    
    func setupLogin() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            print("\(uid)でログインしています")
        } else {
            auth()
        }
    }
    
    func setupTrashButton() {
        trashButton = UIButton()
        trashButton.setImage(UIImage(systemName: .trashImageSystemName), for: .normal)
        
        trashButton.tintColor = .black
        trashButton.backgroundColor = .baseColor
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
        collectionView.addSubview(trashButton)
        
        let buttonWidth: CGFloat = 55
        
        [trashButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
         trashButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
         trashButton.widthAnchor.constraint(equalToConstant: buttonWidth),
         trashButton.heightAnchor.constraint(equalTo: trashButton.widthAnchor)
        ].forEach { $0.isActive = true }
        
        trashButton.layer.cornerRadius = buttonWidth / 2
        
        trashButton.layer.shadowColor = UIColor.black.cgColor
        trashButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        trashButton.layer.shadowOpacity = 0.7
        trashButton.layer.shadowRadius = 10
        
        trashButton.isHidden = true
    }
    
    func setupStockButton() {
        stockButton = UIButton()
        stockButton.setImage(UIImage(systemName: .stockButtonImageSystemName), for: .normal)
        
        stockButton.tintColor = .black
        stockButton.backgroundColor = .systemYellow
        stockButton.translatesAutoresizingMaskIntoConstraints = false
        stockButton.addTarget(self, action: #selector(stockButtonTapped), for: .touchUpInside)
        collectionView.addSubview(stockButton)
        
        let buttonWidth: CGFloat = 55
        
        [stockButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
         stockButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
         stockButton.widthAnchor.constraint(equalToConstant: buttonWidth),
         stockButton.heightAnchor.constraint(equalTo: stockButton.widthAnchor)
        ].forEach { $0.isActive = true }
        
        stockButton.layer.cornerRadius = buttonWidth / 2
        
        stockButton.layer.shadowColor = UIColor.black.cgColor
        stockButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        stockButton.layer.shadowOpacity = 0.7
        stockButton.layer.shadowRadius = 10
        
        stockButton.isHidden = false
        
    }
    
    func setupPresenter() {
        let reviewManagementModel = ReviewManagementModel()
        let reviewManagementPresenter = ReviewManagementPresenter(view: self, model: reviewManagementModel)
        inject(presenter: reviewManagementPresenter)
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: .setNavigationTitleLeft(title: .reviewTitle))
        
        let sortMenu = UIMenu.makeSortMenuForReview(presenter: presenter)
        sortButton = UIBarButtonItem(title: presenter.returnSortState().buttonTitle, image: nil, primaryAction: nil, menu: sortMenu)
        editButton = editButtonItem
        [sortButton, editButton].forEach { $0?.tintColor = .stringColor }
        
        navigationItem.rightBarButtonItems = [editButton, sortButton]
        
    }
    
    private func setupTabBarController() {
        tabBarController?.tabBar.tintColor = .baseColor
    }
        
    func setupCollectionView() {
        colunmFlowLayout = ColumnFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: colunmFlowLayout)
        collectionView.autoresizingMask = [ .flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .black
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        [collectionView.topAnchor.constraint(equalTo: view.topAnchor),
         collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
         collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ].forEach { $0.isActive = true}
        collectionView.allowsMultipleSelection = true
        collectionView.register(ReviewManagementCollectionViewCell.nib, forCellWithReuseIdentifier: ReviewManagementCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    
    func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(updateReviewManagementCollectionView),
                                       name: .insertReview,
                                       object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logout),
                                               name: .logout,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(login),
                                               name: .login,
                                               object: nil)
    }

    private func setupBanner() {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)

        addBannerViewToView(bannerView)

        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"  // テスト用ID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        GADAdSizeFromCGSize(CGSize(width: view.bounds.width, height: 50))
    }

}

// MARK: - @objc
extension ReviewManagementCollectionViewController {
    @objc func trashButtonTapped() {
        let deleteAlert = UIAlertController(title: nil, message: .deleteAlertMessage, preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: .deleteAlertTitle, style: .destructive, handler: { _ in
            guard let reviewSortedIndex = (self.collectionView.indexPathsForSelectedItems?.sorted { $0 > $1 }) else { return }
            self.presenter.didDeleteReviewMovie(.delete, indexPaths: reviewSortedIndex)
        }))
        deleteAlert.addAction(UIAlertAction(title: .cancelAlert, style: .cancel, handler: nil))
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    @objc func stockButtonTapped() {
        let stockReviewMovieVC = UIStoryboard(name: .StockReviewMovieManagementStoryboardName, bundle: nil).instantiateInitialViewController() as! StockReviewMovieManagementViewController
        let model = StockReviewMovieManagementModel()
        let presenter = StockReviewMovieManagementPresenter(view: stockReviewMovieVC, model: model)
        stockReviewMovieVC.inject(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: stockReviewMovieVC)
//        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func updateReviewManagementCollectionView() {
        presenter.fetchUpdateReviewMovies(state: .insert)
    }
    
    @objc func logout() {
        presenter.didLogout()
    }
    
    @objc func login() {
        presenter.fetchUpdateReviewMovies(state: .initial)
    }
    
}

// MARK: - UICollectionViewDelegate
extension ReviewManagementCollectionViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ReviewManagementCollectionViewCell else { return }
        if isEditing {
            cell.tapCell(state: .selected)
            collectionView.indexPathsForSelectedItems == [] ? (trashButton.isEnabled = false) : (trashButton.isEnabled = true)
        } else {
            presenter.didSelectRowCollectionView(at: indexPath)
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing == true {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ReviewManagementCollectionViewCell else { return }
            cell.tapCell(state: .deselected)
            collectionView.indexPathsForSelectedItems == [] ? (trashButton.isEnabled = false) : (trashButton.isEnabled = true)
        }
        
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ReviewManagementCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(1)
    }
    
}


// MARK: - UICollectionViewDataSource
extension ReviewManagementCollectionViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(presenter.numberOfMovies)
        return presenter.numberOfMovies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewManagementCollectionViewCell.identifier, for: indexPath) as! ReviewManagementCollectionViewCell
        let movieReviews = presenter.returnMovieReviewForCell(forRow: indexPath.row)
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
            cell.configure(movieReview: movieReviews, cellSelectedState: .selected)
        } else {
            cell.configure(movieReview: movieReviews, cellSelectedState: .deselected)
        }

        return cell
    }
    
}

// MARK: - ReviewManagementPresenterOutput
extension ReviewManagementCollectionViewController : ReviewManagementPresenterOutput {
    
    func sortReview() {
        if presenter.numberOfMovies > 1 { // cellの数が0か1の時は、並び替えても意味がないので
            for index in 0...presenter.numberOfMovies - 1 {
                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
        sortButton.title = presenter.returnSortState().buttonTitle
        print("\(presenter.returnSortState().buttonTitle)に並び替えました。review")

    }
    
    
    // MARK: 初期化、削除、挿入、修正を行う
    func updateReview(_ movieUpdateState: MovieUpdateState, index: Int?) {
        switch movieUpdateState {
        case .initial:
            collectionView.reloadData()
            
        case .delete:
            guard let index = index else { return }
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            }
            
            
        case .insert:
            if presenter.numberOfMovies == 0 || presenter.numberOfMovies == 1 {
                collectionView.reloadData()
            } else {
                for index in 0...presenter.numberOfMovies - 1 {
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
            
        case .modificate:
            if presenter.numberOfMovies == 0 || presenter.numberOfMovies == 1 {
                collectionView.reloadData()
            } else {
                for index in 0...presenter.numberOfMovies - 1 {
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
            
        }
        
        isEditing = false
    }
    
    // MARK: 選択解除を行う
    func changeTheDisplayDependingOnTheEditingState(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        switch editing {
        case true:
            tabBarController?.tabBar.isHidden = true
            sortButton.isEnabled = false
            trashButton.isHidden = false
            trashButton.isEnabled = false
            stockButton.isHidden = true
            editButton.title = .deselectTitle
            // trueになった時、一旦全選択解除
            guard let indexPaths = indexPaths else { return }
            for index in indexPaths {
                collectionView.deselectItem(at: index, animated: true)
            }

        case false:
            tabBarController?.tabBar.isHidden = false
            sortButton.isEnabled = true
            trashButton.isHidden = true
            stockButton.isHidden = false
            editButton.title = .selectTitle
            // falseになった時も、全選択解除して、cell選択時のエフェクトも解除
            guard let indexPaths = indexPaths else { return }
            for index in indexPaths {
                collectionView.deselectItem(at: index, animated: true)
                collectionView.reloadItems(at: [IndexPath(item: index.row, section: 0)])
            }
        }
    }
    
    
    // MARK: tapしたレビューを詳細表示
    func displaySelectMyReview(_ movie: MovieReviewElement, afterStoreState: afterStoreState, movieUpdateState: MovieUpdateState) {
        let reviewMovieVC = UIStoryboard(name: .reviewMovieStoryboardName, bundle: nil).instantiateInitialViewController() as! ReviewMovieViewController
        let model = ReviewMovieModel(movie: movie, movieReviewElement: movie)
        let presenter = ReviewMoviePresenter(movieReviewState: .afterStore(afterStoreState), movieReviewElement: movie, movieUpdateState: movieUpdateState, view: reviewMovieVC, model: model)
        reviewMovieVC.inject(presenter: presenter)
        
        let navigationController = UINavigationController(rootViewController: reviewMovieVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
}

extension ReviewManagementCollectionViewController : FUIAuthDelegate {
    private func auth() {
        if let authUI = FUIAuth.defaultAuthUI() {
            authUI.providers = [
                FUIOAuth.appleAuthProvider(),
                FUIGoogleAuth(authUI: authUI),
                FUIOAuth.twitterAuthProvider()
            ]
            authUI.delegate = self
            
            let authViewController = authUI.authViewController()
            self.present(authViewController, animated: true)
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            print("\(user.uid)でサインインしました。emailは\(user.email ?? "")です。アカウントは\(user.displayName ?? "")")
            presenter.fetchUpdateReviewMovies(state: .initial)
        }
    }

}

extension ReviewManagementCollectionViewController : GADBannerViewDelegate {
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
