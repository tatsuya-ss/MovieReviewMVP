//
//  ViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import UIKit
import GoogleMobileAds

class SearchMovieViewController: UIViewController {
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var displayLabel: UILabel!
    var bannerView: GADBannerView!
    @IBOutlet weak var tableViewBottomAnchor: NSLayoutConstraint!
    
    var scrollIndicator: UIActivityIndicatorView!
    var isLoadingMore = false

    
    private var tableViewCellHeight: CGFloat?
    private var searchMovieViewController: SearchMovieViewController!
    private var presenter: SearchMoviePresenterInput!
    
    func inject(presenter: SearchMoviePresenterInput) {
        self.presenter = presenter
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        movieSearchBar.delegate = self
        movieSearchBar.keyboardType = .namePhonePad
        presenter.fetchMovie(state: .upcoming, text: nil)
    }
    
}

// MARK: - setup
private extension SearchMovieViewController {
    
    private func setup() {
        setupTabBarController()
        setupNavigationController()
        setupTableViewController()
        setupPresenter()
        setupIndicator()
        setupBanner()
    }
    
    
    private func setupTabBarController() {
        tabBarController?.tabBar.tintColor = .baseColor
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: .setNavigationTitleLeft(title: .searchTitle))
    }
    
    private func setupTableViewController() {
        tableView.register(MovieTableViewCell.nib, forCellReuseIdentifier: MovieTableViewCell.reuserIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        // MARK: tableViewの高さを設定
        
        if let height = tableViewCellHeight {
            tableView.rowHeight = height
            tableView.estimatedRowHeight = height
        } else {
            tableViewCellHeight = tableView.bounds.height / 5
            guard let height = tableViewCellHeight else { return }
            tableView.rowHeight = height
            tableView.estimatedRowHeight = height
        }
        
    }
    
    func setupIndicator() {
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
        let searchMovieModel = SearchMovieModel()
        let searchMoviePresenter = SearchMoviePresenter(view: self, model: searchMovieModel)
        self.inject(presenter: searchMoviePresenter)
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

    func addBannerViewToView(_ bannerView: GADBannerView) {
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
@objc extension SearchMovieViewController {
    func handleRefreshControl() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.presenter.fetchMovie(state: .search(.refresh), text: nil)
        })
        tableView.refreshControl?.endRefreshing()
    }
}

// MARK: - UISearchBarDelegate
extension SearchMovieViewController : UISearchBarDelegate {
    // MARK: 検索ボタンが押された時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: 入力中に呼ばれる
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if searchBar.text?.isEmpty == false {
                self.presenter.fetchMovie(state: .search(.initial), text: searchBar.text)
            }
        })
        return true
    }
    
    // MARK: 入力確定後に呼ばれる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if searchBar.text?.isEmpty == true {
                self.presenter.fetchMovie(state: .upcoming, text: nil)
            }
        })
    }
    
    // MARK: キャンセルボタンが押された時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        presenter.fetchMovie(state: .upcoming, text: nil)
        searchBar.resignFirstResponder()
        
    }

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
        
        if isLoadingMore == true {
            scrollView.contentInset.bottom = previousScrollViewBottomInset + indicatorHeight
        } else {
            scrollView.contentInset.bottom = previousScrollViewBottomInset
        }
        
        
        if canLoadFromBottom, difference <= -120 {
            isLoadingMore = true
            
            scrollIndicator.isHidden = false
            scrollIndicator.startAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                self.presenter.fetchMovie(state: .search(.refresh), text: nil)
                self.scrollIndicator.stopAnimating()
                self.scrollIndicator.isHidden = true
                self.isLoadingMore = false
            }
        }
        
    }
}

// MARK: - UITableViewDataSource

extension SearchMovieViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuserIdentifier, for: indexPath) as! MovieTableViewCell
        cell.resetCell()

        let movies = presenter.movie()
        if let tableViewHeight = tableViewCellHeight {
            cell.configureCell(movie: movies[indexPath.row], height: tableViewHeight)
        } else {
            cell.configureCell(movie: movies[indexPath.row], height: tableView.bounds.height / 5)
        }

        return cell
    }
}

// MARK: - SearchMoviePresenterOutput

extension SearchMovieViewController : SearchMoviePresenterOutput {

    func update(_ fetchState: FetchMovieState, _ movie: [MovieReviewElement]) {
        displayLabel.text = fetchState.displayLabelText
        tableView.reloadData()
    }
    
    func reviewTheMovie(movie: MovieReviewElement, movieUpdateState: MovieUpdateState) {
        let reviewMovieVC = UIStoryboard(name: .reviewMovieStoryboardName, bundle: nil).instantiateInitialViewController() as! ReviewMovieViewController
        
        let model = ReviewMovieModel(movie: movie, movieReviewElement: nil)
        
        let presenter = ReviewMoviePresenter(movieReviewState: .beforeStore, movieReviewElement: movie, movieUpdateState: movieUpdateState, view: reviewMovieVC, model: model)
        
        reviewMovieVC.inject(presenter: presenter)
        
        let nav = UINavigationController(rootViewController: reviewMovieVC)
                
        self.present(nav, animated: true, completion: nil)

    }

}

extension SearchMovieViewController : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        let bannerHeight = CGFloat(50)
        tableViewBottomAnchor.constant = -bannerHeight

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
