//
//  Recomendations.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2022/01/02.
//

import Foundation

struct Recommendation {
    private(set) var videoWorks: [VideoWork] = []
    let title: String
    
    mutating func fetchVideoWorks(videoWorks: [VideoWork]) {
        self.videoWorks = videoWorks
    }
    
    mutating func fetchPosterData(index: Int, data: Data) {
        videoWorks[index].posterData = data
    }
}

struct Recommendations {
    private(set) var nowPlaying = Recommendation(title: "公開中")
    private(set) var upcoming = Recommendation(title: "近日公開")
    private(set) var trendingWeek = Recommendation(title: "１週間のトレンド")
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
    
    mutating func fetchNowPlaying(videoWorks: [VideoWork]) {
        nowPlaying.fetchVideoWorks(videoWorks: videoWorks)
    }
    
    mutating func fetchUpcoming(videoWorks: [VideoWork]) {
        upcoming.fetchVideoWorks(videoWorks: videoWorks)
    }
    
    mutating func fetchTrendingWeek(videoWorks: [VideoWork]) {
        trendingWeek.fetchVideoWorks(videoWorks: videoWorks)
    }
    
    mutating func fetchNowPlayingPosterData(index: Int, data: Data) {
        nowPlaying.fetchPosterData(index: index, data: data)
    }
    
    mutating func fetchUpcomingPosterData(index: Int, data: Data) {
        upcoming.fetchPosterData(index: index, data: data)
    }
    
    mutating func fetchTrendingWeekPosterData(index: Int, data: Data) {
        trendingWeek.fetchPosterData(index: index, data: data)
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
