//
//  Recomendations.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2022/01/02.
//

import Foundation

struct Recomendation {
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
