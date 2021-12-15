//
//  SearchMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

protocol SearchMoviePresenterInput {
    var numberOfMovies: Int { get }
    func returnReview(indexPath: IndexPath) -> MovieReviewElement
    func didSelectRow(at indexPath: IndexPath)
    func didSaveReview()
    func fetchMovie(state: FetchMovieState, text: String?)
    func makeTitle(indexPath: IndexPath) -> String
    func makeReleaseDay(indexPath: IndexPath) -> String
}

protocol SearchMoviePresenterOutput : AnyObject {
    func update(_ fetchState: FetchMovieState, _ movie: [MovieReviewElement])
    func reviewTheMovie(movie: MovieReviewElement, movieUpdateState: MovieUpdateState)
    func displayStoreReviewController()
}

final class SearchMoviePresenter : SearchMoviePresenterInput {
    
    private weak var view: SearchMoviePresenterOutput!
    private var useCase: VideoWorkUseCaseProtocol
    private let reviewManagement = ReviewManagement()
    private var cachedSearchConditions = CachedSearchConditions()
    
    init(view: SearchMoviePresenterOutput,
         useCase: VideoWorkUseCaseProtocol) {
        self.view = view
        self.useCase = useCase
    }
    
    var numberOfMovies: Int {
        reviewManagement.returnNumberOfReviews()
    }
    
    func makeTitle(indexPath: IndexPath) -> String {
        reviewManagement.makeTitle(indexPath: indexPath)
    }
    
    func makeReleaseDay(indexPath: IndexPath) -> String {
        reviewManagement.makeReleaseDay(indexPath: indexPath)
    }
    
    func returnReview(indexPath: IndexPath) -> MovieReviewElement {
        reviewManagement.returnReviews()[indexPath.item]
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let selectResult = reviewManagement.returnSelectedReview(indexPath: indexPath)
        view.reviewTheMovie(movie: selectResult, movieUpdateState: .insert)
    }
    
    func didSaveReview() {
        let saveCount = UserDefaults.standard.loadNumberOfSaves()
        if saveCount % 10 == 0 {
            view.displayStoreReviewController()
        }
    }
    
    func fetchMovie(state: FetchMovieState, text: String?) {
        let dispatchGroup = DispatchGroup()
        switch state {
        case .search(.initial):
            guard let query = text,
                  !query.isEmpty else { return }
            cachedSearchConditions.cachedQuery(query: query)
            cachedSearchConditions.initialPage()
            dispatchGroup.enter()
            useCase.fetchVideoWorks(page: cachedSearchConditions.page, query: query) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let results):
                    self?.reviewManagement.fetchReviews(state: state, results: results)
                    self?.fetchPosterImage(results: results, dispatchGroup: dispatchGroup)
                    dispatchGroup.notify(queue: .main) {
                        self?.view.update(state, results)
                    }
                }
            }
            
        case .search(.refresh):
            guard let query = cachedSearchConditions.cachedQuery else { return }
            cachedSearchConditions.countUpPage()
            dispatchGroup.enter()
            useCase.fetchVideoWorks(page: cachedSearchConditions.page, query: query) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let results):
                    self?.reviewManagement.fetchReviews(state: state, results: results)
                    guard let reviews = self?.reviewManagement.returnReviews() else { return }
                    self?.fetchPosterImage(results: reviews, dispatchGroup: dispatchGroup)
                    dispatchGroup.notify(queue: .main) {
                        self?.view.update(state, results)
                    }
                }
            }
            
        case .upcoming:
            dispatchGroup.enter()
            useCase.fetchUpcomingVideoWorks { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let results):
                    self?.reviewManagement.fetchReviews(state: state, results: results)
                    self?.fetchPosterImage(results: results, dispatchGroup: dispatchGroup)
                    dispatchGroup.notify(queue: .main) {
                        self?.view.update(state, self?.reviewManagement.returnReviews() ?? [])
                    }
                    
                }
            }
        }
    }
    
    private func fetchPosterImage(results: [MovieReviewElement], dispatchGroup: DispatchGroup) {
        results.enumerated().forEach { movieReviewElement in
            dispatchGroup.enter()
            useCase.fetchPosterImage(posterPath: movieReviewElement.element.poster_path) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    self?.reviewManagement.fetchPosterData(index: movieReviewElement.offset, data: data)
                }
            }
        }
    }
}
