//
//  VideoWorksRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/07.
//

import Foundation

protocol VideoWorksRepositoryProtocol {
    func fetchVideoWorks(page: Int, query: String,
                         completion: @escaping ResultHandler<[VideoWork]>)
    func fetchRecommendVideoWorks(url: URL, completion: @escaping ResultHandler<[VideoWork]>)
    func fetchVideoWorkDetail(videoWork: VideoWork,
                              completion: @escaping ResultHandler<[CastDetail]>)
    func fetchPosterImage(posterPath: String?, completion: @escaping ResultHandler<Data>)
}

final class VideoWorksRepository: VideoWorksRepositoryProtocol {
    
    private var dataStore: TMDbDataStoreProtocol
    init(dataStore: TMDbDataStoreProtocol = TMDbDataStore()) {
        self.dataStore = dataStore
    }
    
    func fetchVideoWorks(page: Int,
                         query: String,
                         completion: @escaping ResultHandler<[VideoWork]>) {
        dataStore.fetchVideoWorks(page: page,
                                  query: query) { result in
            switch result {
            case .success(let tmdbVideoWorks):
                let videoWorks = tmdbVideoWorks.results.map { VideoWork(data: $0) }
                completion(.success(videoWorks))
            case.failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchVideoWorkDetail(videoWork: VideoWork,
                              completion: @escaping ResultHandler<[CastDetail]>) {
        dataStore.fetchVideoWorkDetail(videoWork: videoWork) { result in
            switch result {
            case .success(let tmdbCredits):
                let credits = tmdbCredits.cast.map { CastDetail(cast: $0) }
                completion(.success(credits))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchRecommendVideoWorks(url: URL, completion: @escaping ResultHandler<[VideoWork]>) {
        dataStore.fetchRecommendVideoWorks(url: url) { result in
            switch result {
            case .success(let tmdbVideoWorks):
                let videoWorks = tmdbVideoWorks.results
                    .map { VideoWork(data: $0) }
                completion(.success(videoWorks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPosterImage(posterPath: String?,
                          completion: @escaping ResultHandler<Data>) {
        dataStore.fetchPosterImage(posterPath: posterPath, completion: completion)
    }
    
}

private extension VideoWork {
    init(data: TMDbVideoWork) {
        self = VideoWork(title: data.title,
                         posterPath: data.posterPath,
                         originalName: data.originalName,
                         backdropPath: data.backdropPath,
                         overview: data.overview,
                         releaseDay: data.releaseDay,
                         reviewStars: data.reviewStars,
                         review: data.review,
                         createAt: data.createAt,
                         id: data.id,
                         isStoredAsReview: data.isStoredAsReview,
                         mediaType: data.mediaType)
    }
}

private extension CastDetail {
    init(cast: TMDbCastDetail) {
        self = CastDetail(id: cast.id,
                          profilePath: cast.profilePath, name: cast.name)
    }
}

private extension CrewDetail {
    init(crew: TMDbCrewDetail) {
        self = CrewDetail(id: crew.id,
                          profilePath: crew.profilePath,
                          job: crew.job, name: crew.name)
    }
}
