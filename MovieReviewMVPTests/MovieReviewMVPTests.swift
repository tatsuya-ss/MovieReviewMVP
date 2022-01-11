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
