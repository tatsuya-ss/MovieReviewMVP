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
    
    private enum SectionKind: Int, CaseIterable {
        case upcoming
        case trendingWeek
        case nowPlaying
        var title: String {
            switch self {
            case .upcoming: return "近日公開"
            case .trendingWeek: return "１週間のトレンド"
            case .nowPlaying: return "公開中"
            }
        }
    }
    
    @IBOutlet private weak var movieSearchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView!
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
        setupPresenter()
        setupIndicator()
        setupSearchBar()
        setupBanner()
        setupIndicator(indicator: activityIndicatorView)
        startIndicator(indicator: activityIndicatorView)
        setupCollectionView()
        configureRecommendationDataSource()
        presenter.fetchMovie(state: .recommend, text: nil)
    }
    
    @IBAction func saveButtonTappedForInsertSegue(segue: UIStoryboardSegue) {
        presenter.didSaveReview()
    }
    
}

// MARK: - func
extension SearchMovieViewController {
    
    private func collectionViewRecommendationSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, VideoWork>()
        for section in (0..<presenter.numberOfRecommendationSections) {
            snapshot.appendSections([section])
            snapshot.appendItems(presenter.returnRecomendedVideoWorks()[section])
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func collectionViewSearchResultSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, VideoWork>()
        snapshot.appendSections([presenter.numberOfSearchResultSections])
        snapshot.appendItems(presenter.returnSearchResults())
        dataSource.apply(snapshot, animatingDifferences: true)
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
        collectionView.collectionViewLayout = createRecommendationLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(SearchMovieCollectionViewCell.nib, forCellWithReuseIdentifier: SearchMovieCollectionViewCell.identifier)
        collectionView.register(SearchResultCollectionViewCell.nib, forCellWithReuseIdentifier: SearchResultCollectionViewCell.identifier)
        collectionView.backgroundColor = .black
        collectionView.delegate = self
    }
    
    private func configureSearchResultDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, VideoWork>(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCollectionViewCell.identifier, for: indexPath) as? SearchResultCollectionViewCell else { return UICollectionViewCell() }
            let movie = self?.presenter.returnSearchResult(indexPath: indexPath)
                   let image = (movie?.posterData == nil) ? UIImage(named: "no_image") : UIImage(data: (movie?.posterData!)!)
                   let title = self?.presenter.makeSearchResultTitle(indexPath: indexPath) ?? "タイトル無し"
                   let releaseDay = self?.presenter.makeSearchResultReleaseDay(indexPath: indexPath) ?? "公開日不明"
                   cell.configure(image: image, title: title, releaseDay: releaseDay)
                   return cell
               })
        // MARK: Headerの作成
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<CollectionViewHeaderTitle>(elementKind: "header-element-kind") { supplementaryView, elementKind, indexPath in
            supplementaryView.label.text = "検索結果"
            supplementaryView.label.textColor = .white
            supplementaryView.label.font = .boldSystemFont(ofSize: 20)
        }
        dataSource.supplementaryViewProvider = { [weak self] (view, kind, index) in
            return self?.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, VideoWork>()
        snapshot.appendSections([presenter.numberOfSearchResultSections])
        snapshot.appendItems(presenter.returnSearchResults())
        print(presenter.returnSearchResults())
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureRecommendationDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, VideoWork>(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchMovieCollectionViewCell.identifier, for: indexPath) as? SearchMovieCollectionViewCell else { return UICollectionViewCell() }
            let movie = self?.presenter.returnRecomendedVideoWorks()[indexPath.section][indexPath.item]
            let image = (movie?.posterData == nil) ? UIImage(named: "no_image") : UIImage(data: (movie?.posterData!)!)
            let title = self?.presenter.makeRecommendationTitle(indexPath: indexPath) ?? "タイトル無し"
            let releaseDay = self?.presenter.makeRecommendationReleaseDay(indexPath: indexPath) ?? "公開日不明"
            cell.configure(image: image, title: title, releaseDay: releaseDay)
            return cell
        })
        
        // MARK: Headerの作成
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<CollectionViewHeaderTitle>(elementKind: "header-element-kind") { supplementaryView, elementKind, indexPath in
            let sectionKind = SectionKind(rawValue: indexPath.section)
            supplementaryView.label.text = sectionKind?.title
            supplementaryView.label.textColor = .white
            supplementaryView.label.font = .boldSystemFont(ofSize: 20)
        }
        dataSource.supplementaryViewProvider = { [weak self] (view, kind, index) in
            return self?.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Int, VideoWork>()
        for section in (0..<presenter.numberOfRecommendationSections) {
            snapshot.appendSections([section])
            snapshot.appendItems(presenter.returnRecomendedVideoWorks()[section])
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func createSearchResultLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection in
            let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                        heightDimension: .fractionalHeight(1.0)))
            leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let containerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                       heightDimension: .fractionalHeight(0.2)),
                                                                    subitems: [leadingItem])
            let section = NSCollectionLayoutSection(group: containerGroup)
            
            // MARK: Headerの処理
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                               heightDimension: .estimated(44)),
                                                                            elementKind: "header-element-kind",
                                                                            alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]

            return section
        }, configuration: config)
        
        return layout
    }
    
    private func createRecommendationLayout() -> UICollectionViewLayout {
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
            
            // MARK: Headerの処理
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                               heightDimension: .estimated(44)),
                                                                            elementKind: "header-element-kind",
                                                                            alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]

            return section
        }, configuration: config)
        
        return layout
    }
    
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
        presenter.changeFetchStateToRecommend()
        searchBar.text = nil
        collectionView.collectionViewLayout = createRecommendationLayout()
        configureRecommendationDataSource()
        searchBar.resignFirstResponder()
        stopIndicator(indicator: activityIndicatorView)
    }
    
}

// MARK: - UICollectionViewDelegate
extension SearchMovieViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieSearchBar.resignFirstResponder()
        presenter.didSelectRow(at: indexPath)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        movieSearchBar.resignFirstResponder()
    }
    
    // MARK: 下部スクロール
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let fetchState = presenter.getFetchState
        if case .search = fetchState {
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

}

// MARK: - SearchMoviePresenterOutput

extension SearchMovieViewController : SearchMoviePresenterOutput {
    
    func initialRecommendation() {
        collectionView.collectionViewLayout = createRecommendationLayout()
        configureRecommendationDataSource()
        collectionViewRecommendationSnapshot()
        stopIndicator(indicator: activityIndicatorView)
    }
    
    func searchInitial() {
        collectionView.collectionViewLayout = createSearchResultLayout()
        configureSearchResultDataSource()
        collectionViewSearchResultSnapshot()
        stopIndicator(indicator: activityIndicatorView)
    }
    
    func searchRefresh() {
        configureSearchResultDataSource()
        collectionViewSearchResultSnapshot()
        stopIndicator(indicator: activityIndicatorView)
    }
    
    func reviewTheMovie(movie: VideoWork, movieUpdateState: MovieUpdateState) {
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

// MARK: - GADBannerViewDelegate
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
