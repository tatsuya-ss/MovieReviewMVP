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
    private let reviewManagement = ReviewManagement()
    
    init(view: SearchMoviePresenterOutput, model: SearchMovieModelInput) {
        self.view = view
        self.model = model
    }
    
    var numberOfMovies: Int {
        reviewManagement.returnNumberOfReviews()
    }
    
    func movie() -> [MovieReviewElement] {
        reviewManagement.returnReviews()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let selectResult = reviewManagement.returnSelectedReview(indexPath: indexPath)
        view.reviewTheMovie(movie: selectResult, movieUpdateState: .insert)
    }
    
    func fetchMovie(state: FetchMovieState, text: String?) {
        model.fetchMovie(fetchState: state, query: text, completion: { [weak self] result in
            switch result {
            case let .success(result):
                switch state {
                case .search(.initial):
                    self?.reviewManagement.fetchReviews(result: result)
                case .search(.refresh):
                    self?.reviewManagement.searchRefresh(result: result)
                case .upcoming:
                    self?.reviewManagement.fetchReviews(result: result)
                }
                DispatchQueue.main.async {
                    self?.view.update(state, result)
                }
                
            case let .failure(SearchError.requestError(error)):
                print(error)
                
            case let .failure(error):
                print(error)
            }
        })

    }
}
