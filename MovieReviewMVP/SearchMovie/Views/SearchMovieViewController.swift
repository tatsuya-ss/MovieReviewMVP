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
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var refreshButton: UIButton!
    
    private var bannerView: GADBannerView!
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
        setupSearchBar()
        setupRefreshButton()
        setupBanner()
        setupNotification()
        setupIndicator(indicator: activityIndicatorView)
        startIndicator(indicator: activityIndicatorView)
        setupCollectionView()
        configureRecommendationDataSource()
        presenter.fetchMovie(state: .recommend, text: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshButton.layer.cornerRadius = refreshButton.bounds.height / 2
    }
    
    @IBAction private func didTapRefreshButton(_ sender: Any) {
        startIndicator(indicator: activityIndicatorView)
        presenter.fetchMovie(state: .search(.refresh), text: nil)
    }
    
}

// MARK: - func
extension SearchMovieViewController {
    
    private func collectionViewRecommendationSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, VideoWork>()
        for section in (0..<presenter.numberOfSections) {
            snapshot.appendSections([section])
            snapshot.appendItems(presenter.getVideoWorks(section: section))
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func collectionViewSearchResultSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, VideoWork>()
        snapshot.appendSections([presenter.numberOfSections])
        snapshot.appendItems(presenter.getVideoWorks(section: 0))
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

// MARK: - SearchMoviePresenterOutput

extension SearchMovieViewController : SearchMoviePresenterOutput {
    
    func changeIsHidden(isHidden: Bool, alpha: Double) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.refreshButton.alpha = alpha
        }, completion:  { [weak self] _ in
            // ここで再度stateを確認しないと、isHiddenが上書きされてしまう。
            // このメソッドはinitialRecommendationより先に呼ばれるが、completion内の処理はinitialRecommendationの後に呼ばれるため
            let fetchState = self?.presenter.getFetchState ?? .recommend
            if case .search = fetchState {
                self?.refreshButton.isHidden = isHidden
            } else {
                self?.refreshButton.isHidden = true
            }
        })
    }
    
    func initialRecommendation() {
        collectionView.collectionViewLayout = createRecommendationLayout()
        configureRecommendationDataSource()
        collectionViewRecommendationSnapshot()
        stopIndicator(indicator: activityIndicatorView)
    }
    
    func searchInitial() {
        collectionView.collectionViewLayout = createSearchResultLayout()
        collectionViewSearchResultSnapshot()
        stopIndicator(indicator: activityIndicatorView)
    }
    
    func searchRefresh() {
        collectionViewSearchResultSnapshot()
        refreshButton.isHidden = true
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

// MARK: - UISearchBarDelegate
extension SearchMovieViewController : UISearchBarDelegate {
    
    // MARK: 検索ボタンが押された時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        startIndicator(indicator: activityIndicatorView)
        configureSearchResultDataSource()
        self.presenter.fetchMovie(state: .search(.initial), text: searchBar.text)
        refreshButton.isHidden = true
        searchBar.resignFirstResponder()
    }
    
    // MARK: キャンセルボタンが押された時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        startIndicator(indicator: activityIndicatorView)
        presenter.changeFetchStateToRecommend()
        searchBar.text = nil
        collectionView.collectionViewLayout = createRecommendationLayout()
        configureRecommendationDataSource()
        collectionViewRecommendationSnapshot()
        refreshButton.isHidden = true
        searchBar.resignFirstResponder()
        stopIndicator(indicator: activityIndicatorView)
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
    
    private func setupRefreshButton() {
        refreshButton.isHidden = true
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(didSaveReview),
                                       name: .insertReview,
                                       object: nil)
    }
    
    @objc private func didSaveReview() {
        let saveCount = UserDefaults.standard.loadNumberOfSaves()
        presenter.didSaveReview(saveCount: saveCount)
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
            let movie = self?.presenter.getVideoWorks(section: 0)[indexPath.item]
                   let image = (movie?.posterData == nil) ? UIImage(named: "no_image") : UIImage(data: (movie?.posterData!)!)
                   let title = self?.presenter.makeTitle(indexPath: indexPath) ?? "タイトル無し"
                   let releaseDay = self?.presenter.makeReleaseDay(indexPath: indexPath) ?? "公開日不明"
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
    }
    
    private func configureRecommendationDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, VideoWork>(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchMovieCollectionViewCell.identifier, for: indexPath) as? SearchMovieCollectionViewCell else { return UICollectionViewCell() }
            let movie = self?.presenter.getVideoWorks(section: indexPath.section)[indexPath.item]
            let image = (movie?.posterData == nil) ? UIImage(named: "no_image") : UIImage(data: (movie?.posterData!)!)
            let title = self?.presenter.makeTitle(indexPath: indexPath) ?? "タイトル無し"
            let releaseDay = self?.presenter.makeReleaseDay(indexPath: indexPath) ?? "公開日不明"
            cell.configure(image: image, title: title, releaseDay: releaseDay)
            return cell
        })
        
        // MARK: Headerの作成
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<CollectionViewHeaderTitle>(elementKind: "header-element-kind") { [weak self] supplementaryView, elementKind, indexPath in
            supplementaryView.label.text = self?.presenter.getHeaderTitle(indexPath: indexPath)
            supplementaryView.label.textColor = .white
            supplementaryView.label.font = .boldSystemFont(ofSize: 20)
        }
        dataSource.supplementaryViewProvider = { [weak self] (view, kind, index) in
            return self?.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
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
            let containerHeightDimention = (sectionIndex == 0) ? 0.4 : 0.3
            let containerWidth = containerHeightDimention * self.view.bounds.height * 18 / 30
            let containerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(containerWidth),
                                                                                                       heightDimension: .fractionalHeight(containerHeightDimention)),
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
        let scroll = scrollView.contentOffset.y + scrollView.frame.size.height
        let cellHeight = collectionView.bounds.height * 0.2
        let isHidden = scrollView.contentSize.height >= scroll + cellHeight
        presenter.didScroll(isHidden: isHidden)
    }
    
}

// MARK: - GADBannerViewDelegate
extension SearchMovieViewController : GADBannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        let bannerHeight = CGFloat(50)
        self.collectionViewBottomAnchor.constant = bannerHeight
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
        print("bannerViewDidReceiveAd")
    }
    
}
