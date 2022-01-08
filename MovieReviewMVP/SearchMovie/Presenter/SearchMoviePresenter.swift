//
//  SearchMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

protocol SearchMoviePresenterInput {
    var numberOfRecommendationSections: Int { get }
    var numberOfSearchResultSections: Int { get }
    var numberOfMovies: Int { get }
    func returnRecomendedVideoWorks() -> [[VideoWork]]
    func returnSearchResult(indexPath: IndexPath) -> VideoWork
    func returnSearchResults() -> [VideoWork]
    var getFetchState: FetchMovieState { get }
    func didSelectRow(at indexPath: IndexPath)
    func didSaveReview()
    func fetchMovie(state: FetchMovieState, text: String?)
    func makeRecommendationTitle(indexPath: IndexPath) -> String
    func makeRecommendationReleaseDay(indexPath: IndexPath) -> String
    func makeSearchResultTitle(indexPath: IndexPath) -> String
    func makeSearchResultReleaseDay(indexPath: IndexPath) -> String
    func changeFetchStateToRecommend()
}

protocol SearchMoviePresenterOutput : AnyObject {
    func searchInitial()
    func searchRefresh()
    func reviewTheMovie(movie: VideoWork, movieUpdateState: MovieUpdateState)
    func displayStoreReviewController()
    func initialRecommendation()
}

final class SearchMoviePresenter : SearchMoviePresenterInput {
    
    private weak var view: SearchMoviePresenterOutput!
    private var useCase: VideoWorkUseCaseProtocol
    private let reviewManagement = ReviewManagement()
    private var cachedSearchConditions = CachedSearchConditions()
    private var recomendations = Recommendations()
    private var fetchState: FetchMovieState = .recommend

    init(view: SearchMoviePresenterOutput,
         useCase: VideoWorkUseCaseProtocol) {
        self.view = view
        self.useCase = useCase
    }
    
    var getFetchState: FetchMovieState {
        fetchState
    }
    
    func changeFetchStateToRecommend() {
        fetchState.changeState(state: .recommend)
    }
    
    var numberOfRecommendationSections: Int {
        recomendations.videoWorks.count
    }
    
    var numberOfSearchResultSections: Int {
        1
    }
    
    func returnRecomendedVideoWorks() -> [[VideoWork]] {
        recomendations.videoWorks
    }
    
    var numberOfMovies: Int {
        reviewManagement.returnNumberOfReviews()
    }
    
    func returnSearchResult(indexPath: IndexPath) -> VideoWork {
        reviewManagement.returnReviews()[indexPath.item]
    }
    
    func returnSearchResults() -> [VideoWork] {
        reviewManagement.returnReviews()
    }
    
    func makeRecommendationTitle(indexPath: IndexPath) -> String {
        recomendations.makeTitle(indexPath: indexPath)
    }
    
    func makeRecommendationReleaseDay(indexPath: IndexPath) -> String {
        recomendations.makeReleaseDay(indexPath: indexPath)
    }
    
    func makeSearchResultTitle(indexPath: IndexPath) -> String {
        reviewManagement.makeTitle(indexPath: indexPath)
    }
    
    func makeSearchResultReleaseDay(indexPath: IndexPath) -> String {
        reviewManagement.makeReleaseDay(indexPath: indexPath)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
//        let selectResult = reviewManagement.returnSelectedReview(indexPath: indexPath)
        let selectResult = recomendations.videoWorks[indexPath.section][indexPath.item]
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
        fetchState.changeState(state: state)
        switch state {
        case .search(.initial):
            guard let query = text,
                  !query.isEmpty else {
                      fetchState.changeState(state: .recommend)
                      view.initialRecommendation()
                      return
                  }
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
                        self?.view.searchInitial()
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
                        self?.view.searchRefresh()
                    }
                }
            }
            
        case .recommend:
            dispatchGroup.enter()
            useCase.fetchRecommendVideoWorks { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let results):
                    self?.recomendations.upcoming.append(videoWorks: results)
                    self?.fetchUpcomingPosterImage(results: results, dispatchGroup: dispatchGroup)
                }
            }
            
            dispatchGroup.enter()
            useCase.fetchTrendingWeekVideoWorks { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let results):
                    self?.recomendations.trendingWeek.append(videoWorks: results)
                    self?.fetchTrendingWeekPosterImage(results: results, dispatchGroup: dispatchGroup)
                }
            }
            
            dispatchGroup.enter()
            useCase.fetchNowPlayingVideoWorks { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let results):
                    print(result)
                    self?.recomendations.nowPlaying.append(videoWorks: results)
                    self?.fetchNowPlayingPosterImage(results: results, dispatchGroup: dispatchGroup)
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.view.initialRecommendation()
            }
            
        }
    }
    
    private func fetchNowPlayingPosterImage(results: [VideoWork], dispatchGroup: DispatchGroup) {
        results.enumerated().forEach { videoWork in
            dispatchGroup.enter()
            useCase.fetchPosterImage(posterPath: videoWork.element.posterPath) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    self?.recomendations.nowPlaying.fetchPosterData(index: videoWork.offset, data: data)
                }
            }
        }
    }
    
    private func fetchTrendingWeekPosterImage(results: [VideoWork], dispatchGroup: DispatchGroup) {
        results.enumerated().forEach { videoWork in
            dispatchGroup.enter()
            useCase.fetchPosterImage(posterPath: videoWork.element.posterPath) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    self?.recomendations.trendingWeek.fetchPosterData(index: videoWork.offset, data: data)
                }
            }
        }
    }
    
    private func fetchUpcomingPosterImage(results: [VideoWork], dispatchGroup: DispatchGroup) {
        results.enumerated().forEach { videoWork in
            dispatchGroup.enter()
            useCase.fetchPosterImage(posterPath: videoWork.element.posterPath) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    self?.recomendations.upcoming.fetchPosterData(index: videoWork.offset, data: data)
                }
            }
        }
    }

    
    private func fetchPosterImage(results: [VideoWork], dispatchGroup: DispatchGroup) {
        results.enumerated().forEach { videoWork in
            dispatchGroup.enter()
            useCase.fetchPosterImage(posterPath: videoWork.element.posterPath) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    self?.reviewManagement.fetchPosterData(index: videoWork.offset, data: data)
                }
            }
        }
    }
}
