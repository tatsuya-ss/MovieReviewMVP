//
//  VideoWorksMock.swift
//  MovieReviewMVPTests
//
//  Created by 坂本龍哉 on 2022/01/12.
//

import Foundation
@testable import MovieReviewMVP

// MARK: - モック作成
extension VideoWork {
    
    static func searchMock() -> [VideoWork] {
        [
            VideoWork(title: "ナルト",
                      reviewStars: 4.0,
                      review: "かっこいい",
                      id: 100),
            
            VideoWork(title: "ナルト疾風伝",
                      reviewStars: 5.0,
                      review: "👏",
                      id: 200)
        ]
    }
    
    static func nowPlayingMock() -> [VideoWork] {
        [
            VideoWork(title: "呪術廻戦", id: 1),
            VideoWork(title: "マトリックス", id: 2),
            VideoWork(title: "あなたの番です", id: 3),
        ]
    }
    
    static func upcomingMock() -> [VideoWork] {
        [
            VideoWork(title: "バイオハザード", id: 4),
            VideoWork(title: "フタリノセカイ", id: 5),
            VideoWork(title: "ノイズ", id: 6),
            VideoWork(title: "前科者", id: 7),
        ]
    }
    
    static func trendingWeekMock() -> [VideoWork] {
        [
            VideoWork(title: "スパイダーマン", id: 8),
            VideoWork(title: "SING2", id: 9),
            VideoWork(title: "ハリーボッター", id: 10),
            VideoWork(title: "ヴェノム", id: 11),
            VideoWork(title: "進撃の巨人", id: 12),
        ]
    }
    
}
