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
    
    var searchMovieViewController: SearchMovieViewController!
    
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
    }
    
    private func setup() {
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: MovieTableViewCell.reuserIdentifier)
    }
}

extension SearchMovieViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.searchEntering()
        })
        return true
    }
    
    func searchEntering() {
        guard let searchText = movieSearchBar.text else { return }
        
        if searchText.isEmpty == true {
            presenter.resetTableView()
        } else {
            presenter.didTapSearchButton(text: searchText)
        }
        
    }
}

extension SearchMovieViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
}

extension SearchMovieViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuserIdentifier, for: indexPath) as! MovieTableViewCell
        
        cell.resetCell()
        
        let movies = presenter.movie()
        
        cell.configureCell(movie: movies[indexPath.row])
        
        return cell
    }
    
    
}

extension SearchMovieViewController : SearchMoviePresenterOutput {
    
    func update(_ movie: [MovieInfomation]) {
        tableView.reloadData()
    }
    
    func reviewTheMovie(movie: MovieInfomation) {
        print(movie)
        
        let reviewMovieVC = UIStoryboard(name: "ReviewMovie", bundle: nil).instantiateInitialViewController() as! ReviewMovieViewController
        
        let model = ReviewMovieModel(movie: movie)
        
        let presenter = ReviewMoviePresenter(movieInfomation: movie, view: reviewMovieVC, model: model)
        
        reviewMovieVC.inject(presenter: presenter)
        
        self.present(reviewMovieVC, animated: true, completion: nil)
        
    }
}
