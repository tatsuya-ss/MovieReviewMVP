//
//  SearchMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

protocol SearchMoviePresenterInput {
    func didTapSearchButton(text: String)
    func resetTableView()
    var numberOfMovies: Int { get }
    func movie() -> [MovieInfomation]
    func didSelectRow(at indexPath: IndexPath)
}

protocol SearchMoviePresenterOutput : AnyObject {
    func update(_ movie: [MovieInfomation])
    func reviewTheMovie(movie: MovieInfomation)
}

final class SearchMoviePresenter : SearchMoviePresenterInput {
    
    func resetTableView() {
        self.movies = []
        self.view.update(movies)
    }
    
    
    private weak var view: SearchMoviePresenterOutput!
    private var model: SearchMovieModelInput
    
    private(set) var movies: [MovieInfomation] = []
    
    init(view: SearchMoviePresenterOutput, model: SearchMovieModelInput) {
        self.view = view
        self.model = model
    }
    
    var numberOfMovies: Int {
        movies.count
    }
    
    func movie() -> [MovieInfomation] {
        movies
    }
    

    func didTapSearchButton(text: String) {
        guard !text.isEmpty else { return }
        
        model.fetchMovie(query: text, completion: { [weak self] result in
            switch result {
            case let .success(movies):
                self?.movies = movies.results
                DispatchQueue.main.async {
                    self?.view.update(movies.results)
                }
            case let .failure(SearchError.requestError(error)):
                print(error)
            case let .failure(error):
                print(error)
            }
        })
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        view.reviewTheMovie(movie: movies[indexPath.row])
    }
}
