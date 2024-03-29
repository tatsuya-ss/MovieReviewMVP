//
//  SearchMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

protocol SearchMoviePresenterInput {
    var numberOfSections: Int { get }
    func getVideoWorks(section: Int) -> [VideoWork]
    var getFetchState: FetchMovieState { get }
    func getHeaderTitle(indexPath: IndexPath) -> String
    func didSelectRow(at indexPath: IndexPath)
    func didSaveReview(saveCount: Int)
    func fetchMovie(state: FetchMovieState, text: String?)
    func makeTitle(indexPath: IndexPath) -> String
    func makeReleaseDay(indexPath: IndexPath) -> String
    func changeFetchStateToRecommend()
    func didScroll(isHidden: Bool)
}

protocol SearchMoviePresenterOutput : AnyObject {
    func searchInitial()
    func searchRefresh()
    func reviewTheMovie(movie: VideoWork, movieUpdateState: MovieUpdateState)
    func displayStoreReviewController()
    func initialRecommendation()
    func changeIsHidden(isHidden: Bool, alpha: Double)
}

final class SearchMoviePresenter : SearchMoviePresenterInput {
    
    private weak var view: SearchMoviePresenterOutput!
    private var useCase: VideoWorkUseCaseProtocol
    private let reviewManagement = ReviewManagement()
    private var cachedSearchConditions = CachedSearchConditions()
    private var recomendations = Recommendations()
    private var fetchState: FetchMovieState = .recommend
    private let sleepTime = RequestTime().sleepTime
    
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
    
    var numberOfSections: Int {
        switch fetchState {
        case .search:
            return 1
        case .recommend:
            return recomendations.videoWorks.count
        }
    }
    
    func getHeaderTitle(indexPath: IndexPath) -> String {
        recomendations.recommendations[indexPath.section].title
    }
    
    func didScroll(isHidden: Bool) {
        if case .search = fetchState {
            let alpha = isHidden ? 0.0 : 1.0
            view.changeIsHidden(isHidden: isHidden, alpha: alpha)
        }
    }
    
    func getVideoWorks(section: Int) -> [VideoWork] {
        switch fetchState {
        case .search:
            return reviewManagement.returnReviews()
        case .recommend:
            return recomendations.videoWorks[section]
        }
    }
    
    func makeTitle(indexPath: IndexPath) -> String {
        switch fetchState {
        case .search:
            return reviewManagement.makeTitle(indexPath: indexPath)
        case .recommend:
            return recomendations.makeTitle(indexPath: indexPath)
        }
    }
    
    func makeReleaseDay(indexPath: IndexPath) -> String {
        switch fetchState {
        case .search:
            return reviewManagement.makeReleaseDay(indexPath: indexPath)
        case .recommend:
            return recomendations.makeReleaseDay(indexPath: indexPath)
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        switch fetchState {
        case .search:
            let selectResult = reviewManagement.returnSelectedReview(indexPath: indexPath)
            view.reviewTheMovie(movie: selectResult, movieUpdateState: .insert)
        case .recommend:
            let selectResult = recomendations.videoWorks[indexPath.section][indexPath.item]
            view.reviewTheMovie(movie: selectResult, movieUpdateState: .insert)
        }
    }
    
    func didSaveReview(saveCount: Int) {
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
                    print(#function, error)
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
                    print(#function, error)
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
            useCase.fetchUpcomingVideoWorks { [weak self] result in
                Thread.sleep(forTimeInterval: RequestTime().sleepTime)
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(#function, error)
                case .success(let results):
                    self?.recomendations.fetchUpcoming(videoWorks: results)
                    self?.fetchUpcomingPosterImage(results: results, dispatchGroup: dispatchGroup)
                }
            }
            
            dispatchGroup.enter()
            useCase.fetchTrendingWeekVideoWorks { [weak self] result in
                Thread.sleep(forTimeInterval: RequestTime().sleepTime)
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(#function, error)
                case .success(let results):
                    self?.recomendations.fetchTrendingWeek(videoWorks: results)
                    self?.fetchTrendingWeekPosterImage(results: results, dispatchGroup: dispatchGroup)
                }
            }
            
            dispatchGroup.enter()
            useCase.fetchNowPlayingVideoWorks { [weak self] result in
                Thread.sleep(forTimeInterval: RequestTime().sleepTime)
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(#function, error)
                case .success(let results):
                    print(result)
                    self?.recomendations.fetchNowPlaying(videoWorks: results)
                    self?.fetchNowPlayingPosterImage(results: results, dispatchGroup: dispatchGroup)
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.view.initialRecommendation()
            }
            
        }
    }
    
}

// MARK: - func
extension SearchMoviePresenter {
    
    private func fetchNowPlayingPosterImage(results: [VideoWork], dispatchGroup: DispatchGroup) {
        results.enumerated().forEach { videoWork in
            Thread.sleep(forTimeInterval: RequestTime().sleepTime)
            dispatchGroup.enter()
            useCase.fetchPosterImage(posterPath: videoWork.element.posterPath) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(#function, error)
                case .success(let data):
                    self?.recomendations.fetchNowPlayingPosterData(index: videoWork.offset, data: data)
                }
            }
        }
    }
    
    private func fetchTrendingWeekPosterImage(results: [VideoWork], dispatchGroup: DispatchGroup) {
        results.enumerated().forEach { videoWork in
            Thread.sleep(forTimeInterval: RequestTime().sleepTime)
            dispatchGroup.enter()
            useCase.fetchPosterImage(posterPath: videoWork.element.posterPath) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(#function, error)
                case .success(let data):
                    self?.recomendations.fetchTrendingWeekPosterData(index: videoWork.offset, data: data)
                }
            }
        }
    }
    
    private func fetchUpcomingPosterImage(results: [VideoWork], dispatchGroup: DispatchGroup) {
        results.enumerated().forEach { videoWork in
            Thread.sleep(forTimeInterval: RequestTime().sleepTime)
            dispatchGroup.enter()
            useCase.fetchPosterImage(posterPath: videoWork.element.posterPath) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(#function, error)
                case .success(let data):
                    self?.recomendations.fetchUpcomingPosterData(index: videoWork.offset, data: data)
                }
            }
        }
    }

    
    private func fetchPosterImage(results: [VideoWork], dispatchGroup: DispatchGroup) {
        results.enumerated().forEach { videoWork in
            Thread.sleep(forTimeInterval: RequestTime().sleepTime)
            dispatchGroup.enter()
            useCase.fetchPosterImage(posterPath: videoWork.element.posterPath) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    print(#function, error)
                case .success(let data):
                    self?.reviewManagement.fetchPosterData(index: videoWork.offset, data: data)
                }
            }
        }
    }
    
}
