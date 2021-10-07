//
//  VideoWorksRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/07.
//

import Foundation

protocol VideoWorksRepositoryProtocol {
    func fetchVideoWorks(fetchState: FetchMovieState, query: String,
                         completion: @escaping ResultHandler<[VideoWork]>)
}

final class VideoWorksRepository: VideoWorksRepositoryProtocol {
    
    private var dataStore: TMDbDataStoreProtocol
    init(dataStore: TMDbDataStoreProtocol) {
        self.dataStore = dataStore
    }
    
    func fetchVideoWorks(fetchState: FetchMovieState,
                         query: String,
                         completion: @escaping ResultHandler<[VideoWork]>) {
        dataStore.fetchVideoWorks(fetchState: fetchState,
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
