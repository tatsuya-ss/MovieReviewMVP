//
//  MovieReviewMVPTests.swift
//  MovieReviewMVPTests
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import XCTest
@testable import MovieReviewMVP

class MovieReviewMVPTests: XCTestCase {
    
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}

final class CachedSearchConditionsTests: XCTestCase {
    
    private var cachedSearchConditions: CachedSearchConditions!
    
    override func setUp() {
        cachedSearchConditions = CachedSearchConditions()
        super.setUp()
    }
    
    func testページ数をプラス１する() {
        cachedSearchConditions.countUpPage()
        XCTAssertEqual(2, cachedSearchConditions.page)
    }
    
    func testページ数を１に初期化する() {
        cachedSearchConditions.countUpPage()
        XCTAssertEqual(2, cachedSearchConditions.page)
        cachedSearchConditions.initialPage()
        XCTAssertEqual(1, cachedSearchConditions.page)
    }
    
    func testクエリをキャッシュする() {
        XCTAssertNil(cachedSearchConditions.cachedQuery)
        let query = "ナルト"
        cachedSearchConditions.cachedQuery(query: query)
        XCTAssertEqual("ナルト", cachedSearchConditions.cachedQuery)
    }
    
}

final class RecommendationsTests: XCTestCase {
    
    private var recommendations: Recommendations!
    
    override func setUp() {
        recommendations = Recommendations()
        super.setUp()
    }
    
    func testおすすめ情報を配列に追加する() {
        let fetchData = [VideoWork(id: 1), VideoWork(id: 2)]
        
        XCTContext.runActivity(named: "おすすめ映画情報を取得した時") { _ in
            
            XCTContext.runActivity(named: "公開中の映画") { _ in
                recommendations.fetchNowPlaying(videoWorks: fetchData)
                XCTAssertEqual(2, recommendations.nowPlaying.videoWorks.count)
            }
            
            XCTContext.runActivity(named: "近日公開の映画") { _ in
                recommendations.fetchUpcoming(videoWorks: fetchData)
                XCTAssertEqual(2, recommendations.upcoming.videoWorks.count)
            }

            XCTContext.runActivity(named: "１週間のトレンドの映画") { _ in
                recommendations.fetchTrendingWeek(videoWorks: fetchData)
                XCTAssertEqual(2, recommendations.trendingWeek.videoWorks.count)
            }
            
        }
        
    }
    
    func test作品のタイトル作成する() {
        
        XCTContext.runActivity(named: "タイトルがある場合") { _ in
            recommendations.fetchNowPlaying(videoWorks: [VideoWork(title: "ナルト", id: 1)])
            XCTAssertEqual("ナルト", recommendations.makeTitle(indexPath: IndexPath(item: 0, section: 0)))
        }
        
        XCTContext.runActivity(named: "タイトルがなくオリジナルネームがある場合") { _ in
            recommendations.fetchNowPlaying(videoWorks: [VideoWork(title: nil, originalName: "ナルト少年編", id: 1)])
            XCTAssertNil(recommendations.nowPlaying.videoWorks[0].title)
            XCTAssertEqual("ナルト少年編", recommendations.makeTitle(indexPath: IndexPath(item: 0, section: 0)))
        }
        
        XCTContext.runActivity(named: "タイトルもオリジナルネームもない場合") { _ in
            recommendations.fetchNowPlaying(videoWorks: [VideoWork(title: nil, originalName: nil, id: 1)])
            XCTAssertNil(recommendations.nowPlaying.videoWorks[0].title)
            XCTAssertNil(recommendations.nowPlaying.videoWorks[0].originalName)
            XCTAssertEqual("タイトルがありません", recommendations.makeTitle(indexPath: IndexPath(item: 0, section: 0)))
        }
        
    }
    
    func testリリース日を作成する() {
        
        XCTContext.runActivity(named: "リリース日がある場合") { _ in
            recommendations.fetchNowPlaying(videoWorks: [VideoWork(releaseDay: "2020年11月11日", id: 1)])
            XCTAssertEqual("(2020年11月11日)", recommendations.makeReleaseDay(indexPath: IndexPath(item: 0, section: 0)))
        }
        
        XCTContext.runActivity(named: "リリース日がない場合") { _ in
            recommendations.fetchNowPlaying(videoWorks: [VideoWork(id: 1)])
            XCTAssertNil(recommendations.nowPlaying.videoWorks[0].releaseDay)
            XCTAssertEqual("", recommendations.makeReleaseDay(indexPath: IndexPath(item: 0, section: 0)))
        }
        
    }
    
}
