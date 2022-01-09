//
//  Recomendations.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2022/01/02.
//

import Foundation

struct Recommendation {
    var videoWorks: [VideoWork] = []
    let title: String
    
    mutating func append(videoWorks: [VideoWork]) {
        self.videoWorks = videoWorks
    }
    
    mutating func fetchPosterData(index: Int, data: Data) {
        videoWorks[index].posterData = data
    }
}

struct Recommendations {
    var nowPlaying = Recommendation(title: "公開中")
    var upcoming = Recommendation(title: "近日公開")
    var trendingWeek = Recommendation(title: "１週間のトレンド")
    var recommendations: [Recommendation] {
        [nowPlaying, upcoming, trendingWeek]
    }
    var videoWorks: [[VideoWork]] {
        [
            nowPlaying.videoWorks,
            upcoming.videoWorks,
            trendingWeek.videoWorks
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
