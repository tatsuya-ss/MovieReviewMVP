//
//  VideoWorkUseCase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/07.
//

import Foundation

protocol VideoWorkUseCaseProtocol {
    func fetchVideoWorks(page: Int, query: String,
                         completion: @escaping ResultHandler<[VideoWork]>)
    func fetchRecommendVideoWorks(completion: @escaping ResultHandler<[VideoWork]>)
    func fetchTrendingWeekVideoWorks(completion: @escaping ResultHandler<[VideoWork]>)
    func fetchNowPlayingVideoWorks(completion: @escaping ResultHandler<[VideoWork]>)
    func fetchVideoWorkDetail(videoWork: VideoWork,
                              completion: @escaping ResultHandler<[CastDetail]>)
    func fetchPosterImage(posterPath: String?, completion: @escaping ResultHandler<Data>)
}

final class VideoWorkUseCase: VideoWorkUseCaseProtocol {
    
    private var repository: VideoWorksRepositoryProtocol
    init(repository: VideoWorksRepositoryProtocol = VideoWorksRepository()) {
        self.repository = repository
    }
    
    func fetchVideoWorks(page: Int, query: String,
                         completion: @escaping ResultHandler<[VideoWork]>) {
        repository.fetchVideoWorks(page: page,
                                   query: query,
                                   completion: completion)
    }
    
    func fetchVideoWorkDetail(videoWork: VideoWork,
                              completion: @escaping ResultHandler<[CastDetail]>) {
        repository.fetchVideoWorkDetail(videoWork: videoWork,
                                        completion: completion)
    }
    
    func fetchRecommendVideoWorks(completion: @escaping ResultHandler<[VideoWork]>) {
        guard let url = TMDbAPI.UpcomingRequest().upcomingURL else {
            completion(.failure(TMDbSearchError.urlError))
            return
        }
        repository.fetchRecommendVideoWorks(url: url, completion: completion)
    }
    
    func fetchTrendingWeekVideoWorks(completion: @escaping ResultHandler<[VideoWork]>) {
        guard let url = TMDbAPI.TrendingWeekRequest().url else {
            completion(.failure(TMDbSearchError.urlError))
            return
        }
        repository.fetchRecommendVideoWorks(url: url, completion: completion)
    }
    
    func fetchNowPlayingVideoWorks(completion: @escaping ResultHandler<[VideoWork]>) {
        guard let url = TMDbAPI.NowPlayingRequest().url else {
            completion(.failure(TMDbSearchError.urlError))
            return
        }
        repository.fetchRecommendVideoWorks(url: url, completion: completion)
    }
    
    func fetchPosterImage(posterPath: String?,
                          completion: @escaping ResultHandler<Data>) {
        repository.fetchPosterImage(posterPath: posterPath, completion: completion)
    }
}
