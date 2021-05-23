//
//  ViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import UIKit

class SearchMovieViewController: UIViewController {
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var displayLabel: UILabel!
    
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
        tableView.dataSource = self
        tableView.delegate = self
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
    }
    
    
    private func setupTabBarController() {
        tabBarController?.tabBar.isTranslucent = false
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "検索"
    }
    
    private func setupTableViewController() {
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: MovieTableViewCell.reuserIdentifier)
        
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
    
    
    private func setupPresenter() {
        let searchMovieModel = SearchMovieModel()
        let searchMoviePresenter = SearchMoviePresenter(view: self, model: searchMovieModel)
        self.inject(presenter: searchMoviePresenter)
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
                self.presenter.fetchMovie(state: .search, text: searchBar.text)
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
        presenter.didSelectRow(at: indexPath)
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
        switch fetchState {
        case .search:
            displayLabel.text = fetchState.displayLabelText
        case .upcoming:
            displayLabel.text = fetchState.displayLabelText
        }
        tableView.reloadData()
    }
    
    func reviewTheMovie(movie: MovieReviewElement) {
        
        let reviewMovieVC = UIStoryboard(name: "ReviewMovie", bundle: nil).instantiateInitialViewController() as! ReviewMovieViewController
        
        let model = ReviewMovieModel(movie: movie, movieReviewElement: nil)
        
        let presenter = ReviewMoviePresenter(movieReviewState: .beforeStore, movieReviewElement: movie, view: reviewMovieVC, model: model)
        
        reviewMovieVC.inject(presenter: presenter)
        
        let nav = UINavigationController(rootViewController: reviewMovieVC)
                
        self.present(nav, animated: true, completion: nil)
    }
}
