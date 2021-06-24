//
//  SearchMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

protocol SearchMoviePresenterInput {
    var numberOfMovies: Int { get }
    func movie() -> [MovieReviewElement]
    func didSelectRow(at indexPath: IndexPath)
    func fetchMovie(state: FetchMovieState, text: String?)
}

protocol SearchMoviePresenterOutput : AnyObject {
    func update(_ fetchState: FetchMovieState, _ movie: [MovieReviewElement])
    func reviewTheMovie(movie: MovieReviewElement, movieUpdateState: MovieUpdateState)
}

final class SearchMoviePresenter : SearchMoviePresenterInput {
    
    private weak var view: SearchMoviePresenterOutput!
    private var model: SearchMovieModelInput
    private(set) var movies: [MovieReviewElement] = []
    private(set) var stockMovies: [MovieReviewElement] = []
    private var movieUpdateState: MovieUpdateState = .insert

    
    init(view: SearchMoviePresenterOutput, model: SearchMovieModelInput) {
        self.view = view
        self.model = model
    }
    
    var numberOfMovies: Int {
        movies.count
    }
    
    func movie() -> [MovieReviewElement] {
        movies
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        view.reviewTheMovie(movie: movies[indexPath.row], movieUpdateState: movieUpdateState)
    }
    
    func fetchMovie(state: FetchMovieState, text: String?) {
        model.fetchMovie(fetchState: state, query: text, completion: { [weak self] result in
            switch result {
            case let .success(movies):
                switch state {
                case .search(.initial):
                    self?.movies = movies
                    
                case .search(.refresh):
                    self?.movies.append(contentsOf: movies)
                    
                case .upcoming:
                    self?.movies = movies
                }
                
                DispatchQueue.main.async {
                    self?.view.update(state, movies)
                }
                
            case let .failure(SearchError.requestError(error)):
                print(error)
                
            case let .failure(error):
                print(error)
            }
        })

    }
}
