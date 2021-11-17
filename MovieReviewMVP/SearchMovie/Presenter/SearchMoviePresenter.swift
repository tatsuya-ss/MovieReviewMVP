//
//  SearchMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

protocol SearchMoviePresenterInput {
    var numberOfMovies: Int { get }
    func returnReview() -> [MovieReviewElement]
    func didSelectRow(at indexPath: IndexPath)
    func didSaveReview()
    func fetchMovie(state: FetchMovieState, text: String?)
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
    
    func returnReview() -> [MovieReviewElement] {
        reviewManagement.returnReviews()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let selectResult = reviewManagement.returnSelectedReview(indexPath: indexPath)
        view.reviewTheMovie(movie: selectResult, movieUpdateState: .insert)
    }
    
    func didSaveReview() {
        let saveCount = UserDefaults.standard.loadNumberOfSaves()
        print(saveCount)
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
                case .success(let result):
                    self?.reviewManagement.fetchReviews(result: result)
                    guard let reviews = self?.reviewManagement.returnReviews() else { return }
                    reviews.enumerated().forEach { movieReviewElement in
                        dispatchGroup.enter()
                        self?.useCase.fetchPosterImage(posterPath: movieReviewElement.element.poster_path) { result in
                            defer { dispatchGroup.leave() }
                            switch result {
                            case .failure(let error):
                                print(error)
                            case.success(let data):
                                self?.reviewManagement.fetchPosterData(index: movieReviewElement.offset, data: data)
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        self?.view.update(state, result)
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
                case .success(let result):
                    self?.reviewManagement.searchRefresh(result: result)
                    guard let reviews = self?.reviewManagement.returnReviews() else { return }
                    reviews.enumerated().forEach { movieReviewElement in
                        dispatchGroup.enter()
                        self?.useCase.fetchPosterImage(posterPath: movieReviewElement.element.poster_path) { result in
                            defer { dispatchGroup.leave() }
                            switch result {
                            case .failure(let error):
                                print(error)
                            case.success(let data):
                                self?.reviewManagement.fetchPosterData(index: movieReviewElement.offset, data: data)
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        self?.view.update(state, result)
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
                case .success(let result):
                    self?.reviewManagement.fetchReviews(result: result)
                    result.enumerated().forEach { movieReviewElement in
                        dispatchGroup.enter()
                        self?.useCase.fetchPosterImage(posterPath: movieReviewElement.element.poster_path) { result in
                            defer { dispatchGroup.leave() }
                            switch result {
                            case .failure(let error):
                                print(error)
                            case .success(let data):
                                self?.reviewManagement.fetchPosterData(index: movieReviewElement.offset, data: data)
                            }
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        self?.view.update(state, self?.reviewManagement.returnReviews() ?? [])
                    }
                    
                }
            }
        }
    }
    
}
