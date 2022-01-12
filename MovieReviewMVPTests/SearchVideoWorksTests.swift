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

    // MARK: add
    func addFetchVideoWorks(result: Result<[VideoWork], Error>) {
        fetchVideoWorksResponses = result
    }
    
    func addFetchPosterImage(result: Result<Data, Error>) {
        fetchPosterImageResponses = result
    }
    
    // MARK: VideoWorkUseCaseProtocolのメソッド
    func fetchVideoWorks(page: Int, query: String, completion: @escaping ResultHandler<[VideoWork]>) {
        guard let responses = fetchVideoWorksResponses
        else {
            fatalError("fetchVideoWorksResponsesが見つかりません")
        }
        completion(responses)
    }
    
    func fetchRecommendVideoWorks(completion: @escaping ResultHandler<[VideoWork]>) {
        print(#function)
    }
    
    func fetchTrendingWeekVideoWorks(completion: @escaping ResultHandler<[VideoWork]>) {
        print(#function)
    }
    
    func fetchNowPlayingVideoWorks(completion: @escaping ResultHandler<[VideoWork]>) {
        print(#function)
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
        print(#function)
    }
    
}

// MARK: - XCTestCase
final class SearchVideoWorks: XCTestCase {
    
    var spy: SearchMoviePresenterOutputSpy!
    var stub: VideoWorkUseCaseStub!
    var videoWorksMock: [VideoWork]!
    
    override func setUp() {
        spy = SearchMoviePresenterOutputSpy()
        stub = VideoWorkUseCaseStub()
        videoWorksMock = VideoWork.mock()
    }
    
    func test検索ボタンタップ時() {
        
        XCTContext.runActivity(named: "検索ワードがある時") { _ in
            let presenter = SearchMoviePresenter(view: spy, useCase: stub)
            stub.addFetchVideoWorks(result: .success(videoWorksMock))
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
