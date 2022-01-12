//
//  SearchVideoWorksTests.swift
//  MovieReviewMVPTests
//
//  Created by 坂本龍哉 on 2022/01/12.
//

import XCTest
@testable import MovieReviewMVP

// MARK: - モックを返すスタブ
final class VideoWorkUseCaseStub: VideoWorkUseCaseProtocol {
    
    var fetchVideoWorksResponses: Result<[VideoWork], Error>?
    var fetchPosterImageResponses: Result<Data, Error>?
    var fetchUpcomingVideoWorksResponses: Result<[VideoWork], Error>?
    var fetchTrendingWeekVideoWorksResponses: Result<[VideoWork], Error>?
    var fetchNowPlayingVideoWorksResponses: Result<[VideoWork], Error>?
    
    // MARK: add
    func addFetchVideoWorks(result: Result<[VideoWork], Error>) {
        fetchVideoWorksResponses = result
    }
    
    func addFetchPosterImage(result: Result<Data, Error>) {
        fetchPosterImageResponses = result
    }
    
    func addFetchUpcomingVideoWorks(result: Result<[VideoWork], Error>) {
        fetchUpcomingVideoWorksResponses = result
    }
    
    func addFetchTrendingWeekVideoWorks(result: Result<[VideoWork], Error>) {
        fetchTrendingWeekVideoWorksResponses = result
    }
    
    func addFetchNowPlayingVideoWorks(result: Result<[VideoWork], Error>) {
        fetchNowPlayingVideoWorksResponses = result
    }
    
    
    // MARK: VideoWorkUseCaseProtocolのメソッド
    func fetchVideoWorks(page: Int, query: String, completion: @escaping ResultHandler<[VideoWork]>) {
        guard let responses = fetchVideoWorksResponses
        else { fatalError("fetchVideoWorksResponsesが見つかりません") }
        completion(responses)
    }
    
    func fetchUpcomingVideoWorks(completion: @escaping ResultHandler<[VideoWork]>) {
        guard let responses = fetchUpcomingVideoWorksResponses
        else { fatalError("fetchRecommendVideoWorksResponsesが見つかりません") }
        completion(responses)
    }
    
    func fetchTrendingWeekVideoWorks(completion: @escaping ResultHandler<[VideoWork]>) {
        guard let responses = fetchTrendingWeekVideoWorksResponses
        else { fatalError("fetchTrendingWeekVideoWorksResponsesが見つかりません") }
        completion(responses)
    }
    
    func fetchNowPlayingVideoWorks(completion: @escaping ResultHandler<[VideoWork]>) {
        guard let responses = fetchNowPlayingVideoWorksResponses
        else { fatalError("fetchNowPlayingVideoWorksResponsesが見つかりません") }
        completion(responses)
    }
    
    func fetchVideoWorkDetail(videoWork: VideoWork, completion: @escaping ResultHandler<[CastDetail]>) {
        print(#function)
    }
    
    func fetchPosterImage(posterPath: String?, completion: @escaping ResultHandler<Data>) {
        guard let responses = fetchPosterImageResponses
        else {
            fatalError("fetchPosterImageResponsesが見つかりません")
        }
        completion(responses)
    }
    
}

// MARK: - スパイ
final class SearchMoviePresenterOutputSpy: SearchMoviePresenterOutput {
    
    private(set) var countOfInvokingSearchInitial = 0
    private(set) var countOfInvokingSearchRefresh = 0
    private(set) var countOfInvokingReviewTheMovie = 0
    private(set) var countOfInvokingDisplayStoreReviewController = 0
    private(set) var countOfInvokingInitialRecommendation = 0
    
    let reviewManagement = ReviewManagement()
    
    var searchInitialCalledWithVideoWorks: (() -> Void)?
    var initialRecommendationCalledWithVideoWorks: (() -> Void)?
    
    func searchInitial() {
        countOfInvokingSearchInitial += 1
        searchInitialCalledWithVideoWorks?()
    }
    
    func searchRefresh() {
        print(#function)
    }
    
    func reviewTheMovie(movie: VideoWork, movieUpdateState: MovieUpdateState) {
        print(#function)
    }
    
    func displayStoreReviewController() {
        print(#function)
    }
    
    func initialRecommendation() {
        countOfInvokingInitialRecommendation += 1
        initialRecommendationCalledWithVideoWorks?()
    }
    
}

// MARK: - XCTestCase
final class SearchVideoWorks: XCTestCase {
    
    var spy: SearchMoviePresenterOutputSpy!
    var stub: VideoWorkUseCaseStub!
    var videoWorksSearchMock: [VideoWork]!
    var videoWorksNowPlayingMock: [VideoWork]!
    var videoWorksUpcomingMock: [VideoWork]!
    var videoWorksTrendingWeekMock: [VideoWork]!

    override func setUp() {
        spy = SearchMoviePresenterOutputSpy()
        stub = VideoWorkUseCaseStub()
        videoWorksSearchMock = VideoWork.searchMock()
        videoWorksNowPlayingMock = VideoWork.nowPlayingMock()
        videoWorksUpcomingMock = VideoWork.upcomingMock()
        videoWorksTrendingWeekMock = VideoWork.trendingWeekMock()
    }
    
    func test初期表示の時() {
        
        XCTContext.runActivity(named: "おすすめ映画情報を取得") { _ in
            let presenter = SearchMoviePresenter(view: spy, useCase: stub)
            stub.addFetchNowPlayingVideoWorks(result: .success(videoWorksNowPlayingMock))
            stub.addFetchUpcomingVideoWorks(result: .success(videoWorksUpcomingMock))
            stub.addFetchTrendingWeekVideoWorks(result: .success(videoWorksTrendingWeekMock))
            stub.addFetchPosterImage(result: .success(Data()))
            let exp = XCTestExpectation(description: "fetchMovie内で呼ばれるfetchUpcomingVideoWorks,fetchTrendingWeekVideoWorks,fetchNowPlayingVideoWorksの実行を待つ")
            spy.initialRecommendationCalledWithVideoWorks = {
                exp.fulfill()
            }
            presenter.fetchMovie(state: .recommend, text: nil)
            wait(for: [exp], timeout: 1)
            XCTAssertEqual(3, presenter.getVideoWorks(section: 0).count)
            XCTAssertEqual(4, presenter.getVideoWorks(section: 1).count)
            XCTAssertEqual(5, presenter.getVideoWorks(section: 2).count)
            XCTAssertEqual("呪術廻戦", presenter.getVideoWorks(section: 0)[0].title)
            XCTAssertEqual("ノイズ", presenter.getVideoWorks(section: 1)[2].title)
            XCTAssertEqual("ヴェノム", presenter.getVideoWorks(section: 2)[3].title)
        }
        
    }
    
    func test検索ボタンタップ時() {
        
        XCTContext.runActivity(named: "検索ワードがある時") { _ in
            let presenter = SearchMoviePresenter(view: spy, useCase: stub)
            stub.addFetchVideoWorks(result: .success(videoWorksSearchMock))
            stub.addFetchPosterImage(result: .success(Data()))
            let exp = XCTestExpectation(description: "fetchMovie内で呼ばれるfetchVideoWorksの実行を待つ")
            spy.searchInitialCalledWithVideoWorks = {
                exp.fulfill()
            }
            presenter.fetchMovie(state: .search(.initial), text: "ナルト")
            wait(for: [exp], timeout: 1)
            XCTAssertEqual(2, presenter.getVideoWorks(section: 0).count)
            XCTAssertTrue(spy.countOfInvokingSearchInitial == 1)
        }
        
        XCTContext.runActivity(named: "検索ワードがない時") { _ in
            print(#function)
        }
        
    }
    
}
