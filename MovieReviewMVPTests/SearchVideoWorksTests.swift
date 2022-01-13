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
    var searchRefreshCalledWithVideoWorks: (() -> Void)?
    
    var reviewTheMovieVideoWork: VideoWork?

    func changeIsHidden(isHidden: Bool, alpha: Double) {
        print(#function)
    }
    
    func searchInitial() {
        countOfInvokingSearchInitial += 1
        searchInitialCalledWithVideoWorks?()
    }
    
    func searchRefresh() {
        countOfInvokingSearchRefresh += 1
        searchRefreshCalledWithVideoWorks?()
    }
    
    func reviewTheMovie(movie: VideoWork, movieUpdateState: MovieUpdateState) {
        countOfInvokingReviewTheMovie += 1
        reviewTheMovieVideoWork = movie
    }
    
    func displayStoreReviewController() {
        print(#function)
    }
    
    func initialRecommendation() {
        countOfInvokingInitialRecommendation += 1
        initialRecommendationCalledWithVideoWorks?()
    }
    
}

// MARK: - func SearchMoviePresenterOutputSpy
extension SearchMoviePresenterOutputSpy {
    
    func initialCountOfInvokingInitialRecommendation() {
        countOfInvokingInitialRecommendation = 0
    }
    
}

// MARK: - XCTestCase
final class SearchVideoWorksTests: XCTestCase {
    
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
            XCTAssertTrue(spy.countOfInvokingInitialRecommendation == 1)
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
            
            XCTContext.runActivity(named: "検索ワードがnilの時") { _ in
                let presenter = SearchMoviePresenter(view: spy, useCase: stub)
                spy.initialCountOfInvokingInitialRecommendation()
                XCTAssertTrue(spy.countOfInvokingInitialRecommendation == 0)
                presenter.fetchMovie(state: .search(.initial), text: nil)
                XCTAssertTrue(spy.countOfInvokingInitialRecommendation == 1)
            }
            
            XCTContext.runActivity(named: "検索ワードが空の時") { _ in
                let presenter = SearchMoviePresenter(view: spy, useCase: stub)
                spy.initialCountOfInvokingInitialRecommendation()
                XCTAssertTrue(spy.countOfInvokingInitialRecommendation == 0)
                presenter.fetchMovie(state: .search(.initial), text: "")
                XCTAssertTrue(spy.countOfInvokingInitialRecommendation == 1)
            }
            
        }
        
    }
    
    func test検索結果更新処理() {
        
        XCTContext.runActivity(named: "更新ボタンを押した時") { _ in
            let presenter = SearchMoviePresenter(view: spy, useCase: stub)
            stub.addFetchVideoWorks(result: .success(videoWorksSearchMock))
            stub.addFetchPosterImage(result: .success(Data()))
            // MARK: 検索ワードのキャッシュが無しだとreturnされるので、最初の検索を実行
            search(presenter: presenter)
            
            // MARK: 今回テストしたいRefresh処理
            let expRefresh = XCTestExpectation(description: "fetchMovie内で呼ばれるfetchVideoWorksの実行を待つ")
            spy.searchRefreshCalledWithVideoWorks = {
                expRefresh.fulfill()
            }
            presenter.fetchMovie(state: .search(.refresh), text: "ナルト")
            wait(for: [expRefresh], timeout: 1)
            XCTAssertEqual(4, presenter.getVideoWorks(section: 0).count)
            XCTAssertTrue(spy.countOfInvokingSearchInitial == 1)
        }
    }
    
    func testセルをタップ時() {
        let presenter = SearchMoviePresenter(view: spy, useCase: stub)
        stub.addFetchVideoWorks(result: .success(videoWorksSearchMock))
        stub.addFetchPosterImage(result: .success(Data()))
        // MARK: 検索ワードのキャッシュが無しだとreturnされるので、最初の検索を実行
        search(presenter: presenter)
        presenter.didSelectRow(at: IndexPath(item: 0, section: 0))
        XCTAssertTrue(spy.countOfInvokingReviewTheMovie == 1)
        XCTAssertEqual("ナルト", spy.reviewTheMovieVideoWork?.title)
    }
    
}

// MARK: - func SearchVideoWorksTests
extension SearchVideoWorksTests {
    
    private func search(presenter: SearchMoviePresenter) {
        let expSearchInitial = XCTestExpectation(description: "fetchMovie内で呼ばれるfetchVideoWorksの実行を待つ")
        spy.searchInitialCalledWithVideoWorks = {
            expSearchInitial.fulfill()
        }
        presenter.fetchMovie(state: .search(.initial), text: "ナルト")
        wait(for: [expSearchInitial], timeout: 1)
        XCTAssertEqual(2, presenter.getVideoWorks(section: 0).count)
        XCTAssertTrue(spy.countOfInvokingSearchInitial == 1)
    }
    
}
