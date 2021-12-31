//
//  ViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import UIKit
import GoogleMobileAds
import StoreKit

extension SearchMovieViewController: UIActivityIndicatorProtocol { }

final class SearchMovieViewController: UIViewController {
    
    @IBOutlet private weak var movieSearchBar: UISearchBar!
//    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var displayLabel: UILabel!
//    @IBOutlet private weak var tableViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet private weak var collectionViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    private var bannerView: GADBannerView!
    
    private var scrollIndicator: UIActivityIndicatorView!
    private var tableViewCellHeight: CGFloat?
    private var presenter: SearchMoviePresenterInput!
    private var dataSource: UICollectionViewDiffableDataSource<Int, VideoWork>! = nil
    
    func inject(presenter: SearchMoviePresenterInput) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
        setupNavigationController()
//        setupTableViewController()
        setupPresenter()
        setupIndicator()
        setupSearchBar()
        setupBanner()
        setupIndicator(indicator: activityIndicatorView)
        startIndicator(indicator: activityIndicatorView)
        setupCollectionView()
        configureDataSource()
        presenter.fetchMovie(state: .upcoming, text: nil)
    }
    
    @IBAction func saveButtonTappedForInsertSegue(segue: UIStoryboardSegue) {
        presenter.didSaveReview()
    }
    
}

// MARK: - setup
extension SearchMovieViewController {
    
    private func setupSearchBar() {
        movieSearchBar.delegate = self
        movieSearchBar.keyboardType = .namePhonePad
        movieSearchBar.searchTextField.backgroundColor = .white
        movieSearchBar.barStyle = .default
        
        // キャンセルボタンを白
        movieSearchBar.tintColor = .white
        // カーソルの色を黒
        UITextField.appearance(whenContainedInInstancesOf: [type(of: movieSearchBar)]).tintColor = .black
    }
    
    private func setupTabBarController() {
        tabBarController?.tabBar.tintColor = .baseColor
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: .setNavigationTitleLeft(title: .searchTitle))
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(SearchMovieCollectionViewCell.nib, forCellWithReuseIdentifier: SearchMovieCollectionViewCell.identifier)
        collectionView.backgroundColor = .black
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, VideoWork>(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchMovieCollectionViewCell.identifier, for: indexPath) as? SearchMovieCollectionViewCell else { return UICollectionViewCell() }
            let movie = self?.presenter.returnReview(indexPath: indexPath)
            let image = (movie?.posterData == nil) ? UIImage(named: "no_image") : UIImage(data: (movie?.posterData!)!)
            let title = self?.presenter.makeTitle(indexPath: indexPath) ?? "タイトル無し"
            let releaseDay = self?.presenter.makeReleaseDay(indexPath: indexPath) ?? "公開日不明"
            cell.configure(image: image, title: title, releaseDay: releaseDay)
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, VideoWork>()
        snapshot.appendSections([1])
        snapshot.appendItems(presenter.returnReview())
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection in
            let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                        heightDimension: .fractionalHeight(1.0)))
            leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let containerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                                                                                       heightDimension: .fractionalHeight(0.3)),
                                                                    subitems: [leadingItem])
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }, configuration: config)
        
        return layout
    }
    
//    private func setupTableViewController() {
//        tableView.register(MovieTableViewCell.nib, forCellReuseIdentifier: MovieTableViewCell.reuserIdentifier)
//        tableView.dataSource = self
//        tableView.delegate = self
//        // MARK: tableViewの高さを設定
//
//        if let height = tableViewCellHeight {
//            tableView.rowHeight = height
//            tableView.estimatedRowHeight = height
//        } else {
//            tableViewCellHeight = tableView.bounds.height / 5
//            guard let height = tableViewCellHeight else { return }
//            tableView.rowHeight = height
//            tableView.estimatedRowHeight = height
//        }
//
//    }
    
    private func setupIndicator() {
        scrollIndicator = UIActivityIndicatorView()
        scrollIndicator.color = .white
        scrollIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollIndicator)
        
        [scrollIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
         scrollIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         scrollIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         scrollIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor)].forEach { $0.isActive = true }
        
        
    }
    
    private func setupPresenter() {
        let videoWorkUseCase = VideoWorkUseCase(repository:
                                                    VideoWorksRepository(dataStore:
                                                                            TMDbDataStore()
                                                                        ))
        let searchMoviePresenter =
        SearchMoviePresenter(view: self,
                             useCase: videoWorkUseCase)
        self.inject(presenter: searchMoviePresenter)
    }
    
    private func setupBanner() {
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        
        addBannerViewToView(bannerView)
        
        bannerView.delegate = self
        
        if let id = adUnitID(key: "banner") {
            bannerView.adUnitID = id
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            let adSize = GADAdSizeFromCGSize(CGSize(width: view.bounds.width, height: 50))
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

// MARK: - UISearchBarDelegate
extension SearchMovieViewController : UISearchBarDelegate {
    // MARK: 検索ボタンが押された時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        startIndicator(indicator: activityIndicatorView)
        self.presenter.fetchMovie(state: .search(.initial), text: searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    // MARK: キャンセルボタンが押された時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        startIndicator(indicator: activityIndicatorView)
        searchBar.text = nil
        presenter.fetchMovie(state: .upcoming, text: nil)
        searchBar.resignFirstResponder()
    }
    
    // MARK: 入力中に呼ばれる
    // TODO: 入力早すぎたらIndex out of rangeが出るので一旦やめる
    //        func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
    //                if searchBar.text?.isEmpty == false {
    //                    self.presenter.fetchMovie(state: .search(.initial), text: searchBar.text)
    //                }
    //            })
    //            return true
    //        }
    
    
}

// MARK: - UITableViewDelegate
extension SearchMovieViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        movieSearchBar.resignFirstResponder()
        presenter.didSelectRow(at: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        movieSearchBar.resignFirstResponder()
    }
    
    // MARK: 下部スクロール
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentSize = scrollView.contentSize.height
        let tableSize = scrollView.frame.size.height
        let canLoadFromBottom = contentSize > tableSize
        // Offset　何かの位置を指し示す際に、基準となる位置からの差（距離、ズレ、相対位置）を表す値のことをオフセット
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = contentSize - tableSize
        let difference = maximumOffset - currentOffset
        
        scrollView.backgroundColor = .black
        
        let previousScrollViewBottomInset = CGFloat(0)
        let indicatorHeight = scrollIndicator.bounds.height + 16
        var isLoadingMore = false
        
        if isLoadingMore == true {
            scrollView.contentInset.bottom = previousScrollViewBottomInset + indicatorHeight
        } else {
            scrollView.contentInset.bottom = previousScrollViewBottomInset
        }
        
        
        if canLoadFromBottom, difference <= -120 {
            isLoadingMore = true
            
            scrollIndicator.isHidden = false
            scrollIndicator.startAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) { [weak self] in
                self?.presenter.fetchMovie(state: .search(.refresh), text: nil)
                self?.scrollIndicator.stopAnimating()
                self?.scrollIndicator.isHidden = true
                isLoadingMore = false
            }
        }
        
    }
}

// MARK: - UITableViewDataSource

//extension SearchMovieViewController : UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        presenter.numberOfMovies
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuserIdentifier, for: indexPath) as! MovieTableViewCell
//        let movie = presenter.returnReview(indexPath: indexPath)
//        let image = (movie.posterData == nil) ? UIImage(named: "no_image") : UIImage(data: movie.posterData!)
//        let title = presenter.makeTitle(indexPath: indexPath)
//        let releaseDay = presenter.makeReleaseDay(indexPath: indexPath)
//        cell.configure(image: image, title: title, releaseDay: releaseDay)
//        return cell
//    }
//
//}

// MARK: - SearchMoviePresenterOutput

extension SearchMovieViewController : SearchMoviePresenterOutput {
    
    func update(_ fetchState: FetchMovieState, _ movie: [VideoWork]) {
        displayLabel.text = fetchState.displayLabelText
        collectionViewSnapshot()
        stopIndicator(indicator: activityIndicatorView)
    }
    
    private func collectionViewSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, VideoWork>()
        snapshot.appendSections([1])
        snapshot.appendItems(presenter.returnReview())
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reviewTheMovie(movie: VideoWork, movieUpdateState: MovieUpdateState) {
        //        let reviewMovieVC = UIStoryboard(name: .reviewMovieStoryboardName, bundle: nil).instantiateInitialViewController() as! ReviewMovieViewController
        let reviewMovieVC = SelectSearchReviewViewController()
        let videoWorkUseCase = VideoWorkUseCase()
        let reviewUseCase = ReviewUseCase(repository: ReviewRepository(dataStore: ReviewDataStore()))
        let userUseCase = UserUseCase(repository: UserRepository(dataStore: UserDataStore()))
        let presenter = SelectSearchReviewPresenter(view: reviewMovieVC, selectedReview: SelectedReview(review: movie), reviewUseCase: reviewUseCase, userUseCase: userUseCase, videoWorkuseCase: videoWorkUseCase)
        
        reviewMovieVC.inject(presenter: presenter)
        
        let nav = UINavigationController(rootViewController: reviewMovieVC)
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func displayStoreReviewController() {
        if let windowScene = UIApplication.shared.windows.first?.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
}

extension SearchMovieViewController : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        let bannerHeight = CGFloat(50)
        collectionViewBottomAnchor.constant = -bannerHeight
        
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
