//
//  VideoWorkUseCase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/07.
//

import Foundation

protocol VideoWorkUseCaseProtocol {
    func fetchVideoWorks(page: Int, query: String,
                         completion: @escaping ResultHandler<[MovieReviewElement]>)
    func fetchUpcomingVideoWorks(completion: @escaping ResultHandler<[MovieReviewElement]>)
    func fetchVideoWorkDetail(videoWork: MovieReviewElement,
                              completion: @escaping ResultHandler<[CastDetail]>)
    func fetchPosterImage(posterPath: String?, completion: @escaping ResultHandler<Data>)
}

final class VideoWorkUseCase: VideoWorkUseCaseProtocol {
    
    private var repository: VideoWorksRepositoryProtocol
    init(repository: VideoWorksRepositoryProtocol = VideoWorksRepository()) {
        self.repository = repository
    }
    
    func fetchVideoWorks(page: Int, query: String,
                         completion: @escaping ResultHandler<[MovieReviewElement]>) {
        repository.fetchVideoWorks(page: page,
                                   query: query,
                                   completion: completion)
    }
    
    func fetchVideoWorkDetail(videoWork: MovieReviewElement,
                              completion: @escaping ResultHandler<[CastDetail]>) {
        repository.fetchVideoWorkDetail(videoWork: videoWork,
                                        completion: completion)
    }
    
    func fetchUpcomingVideoWorks(completion: @escaping ResultHandler<[MovieReviewElement]>) {
        repository.fetchUpcomingVideoWorks(completion: completion)
    }
    
    func fetchPosterImage(posterPath: String?,
                          completion: @escaping ResultHandler<Data>) {
        repository.fetchPosterImage(posterPath: posterPath, completion: completion)
    }
}
