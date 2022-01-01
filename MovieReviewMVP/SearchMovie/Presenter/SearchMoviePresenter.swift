//
//  SearchMoviePresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

protocol SearchMoviePresenterInput {
    var numberOfSections: Int { get }
    var numberOfMovies: Int { get }
    func returnRecomendedVideoWorks() -> [[VideoWork]]
    func returnReview(indexPath: IndexPath) -> VideoWork
    func returnReview() -> [VideoWork]
    func didSelectRow(at indexPath: IndexPath)
    func didSaveReview()
    func fetchMovie(state: FetchMovieState, text: String?)
    func makeTitle(indexPath: IndexPath) -> String
    func makeReleaseDay(indexPath: IndexPath) -> String
}

protocol SearchMoviePresenterOutput : AnyObject {
    func update(_ fetchState: FetchMovieState, _ movie: [VideoWork])
    func reviewTheMovie(movie: VideoWork, movieUpdateState: MovieUpdateState)
    func displayStoreReviewController()
    func initial()
}

protocol VideoWorksProtocol {
    var videoWorks: [VideoWork] { get }
    mutating func append(videoWorks: [VideoWork])
    mutating func fetchPosterData(index: Int, data: Data)
}

struct Recomendation: VideoWorksProtocol {
    var videoWorks: [VideoWork] = []
    
    mutating func append(videoWorks: [VideoWork]) {
        self.videoWorks = videoWorks
    }
    
    mutating func fetchPosterData(index: Int, data: Data) {
        videoWorks[index].posterData = data
    }
}

struct Recomendations {
    var upcoming = Recomendation()
    var trendingWeek = Recomendation()
    var nowPlaying = Recomendation()
    var videoWorks: [[VideoWork]] {
        [
            upcoming.videoWorks,
            trendingWeek.videoWorks,
            nowPlaying.videoWorks
        ]
    }
    
    func makeTitle(indexPath: IndexPath) -> String {
        if let title = videoWorks[indexPath.section][indexPath.item].title, !title.isEmpty {
            return title
        } else if let originalName = videoWorks[indexPath.section][indexPath.item].originalName, !originalName.isEmpty {
            return originalName
        } else {
            return .notTitle
        }
    }
    
    func makeReleaseDay(indexPath: IndexPath) -> String {
        if let releaseDay = videoWorks[indexPath.section][indexPath.item].releaseDay {
            return "(\(releaseDay))"
        } else {
            return ""
        }
    }

}

final class SearchMoviePresenter : SearchMoviePresenterInput {
    
    private weak var view: SearchMoviePresenterOutput!
    private var useCase: VideoWorkUseCaseProtocol
//    private let reviewManagement = ReviewManagement()
    private var cachedSearchConditions = CachedSearchConditions()
    private var recomendations = Recomendations()

    init(view: SearchMoviePresenterOutput,
         useCase: VideoWorkUseCaseProtocol) {
        self.view = view
        self.useCase = useCase
    }
    
    var numberOfSections: Int {
        recomendations.videoWorks.count
    }
    
    func returnRecomendedVideoWorks() -> [[VideoWork]] {
        recomendations.videoWorks
    }
    
    var numberOfMovies: Int {
//        reviewManagement.returnNumberOfReviews()
        0
    }
    
    func makeTitle(indexPath: IndexPath) -> String {
//        reviewManagement.makeTitle(indexPath: indexPath)
        recomendations.makeTitle(indexPath: indexPath)
    }
    
    func makeReleaseDay(indexPath: IndexPath) -> String {
//        reviewManagement.makeReleaseDay(indexPath: indexPath)
        recomendations.makeReleaseDay(indexPath: indexPath)
    }
    
    func returnReview(indexPath: IndexPath) -> VideoWork {
//        reviewManagement.returnReviews()[indexPath.item]
        recomendations.videoWorks[indexPath.section][indexPath.item]
    }
    
    func returnReview() -> [VideoWork] {
//        reviewManagement.returnReviews()
        []
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
//                    self?.reviewManagement.fetchReviews(state: state, results: results)
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
//                    self?.reviewManagement.fetchReviews(state: state, results: results)
//                    guard let reviews = self?.reviewManagement.returnReviews() else { return }
//                    self?.fetchPosterImage(results: reviews, dispatchGroup: dispatchGroup)
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
                self.view.initial()
//                self?.view.update(state, self?.reviewManagement.returnReviews() ?? [])
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
                case .success(let data): break
//                    self?.reviewManagement.fetchPosterData(index: videoWork.offset, data: data)
                }
            }
        }
    }
}
