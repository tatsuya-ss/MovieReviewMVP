//
//  VideoWorkUseCase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/07.
//

import Foundation

protocol VideoWorkUseCaseProtocol {
    func fetchVideoWorks(fetchState: FetchMovieState, query: String,
                         completion: @escaping ResultHandler<[MovieReviewElement]>)
    func fetchUpcomingVideoWorks(completion: @escaping ResultHandler<[MovieReviewElement]>)
}

final class VideoWorkUseCase: VideoWorkUseCaseProtocol {
    
    private var repository: VideoWorksRepositoryProtocol
    init(repository: VideoWorksRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchVideoWorks(fetchState: FetchMovieState, query: String,
                         completion: @escaping ResultHandler<[MovieReviewElement]>) {
        repository.fetchVideoWorks(fetchState: fetchState,
                                   query: query,
                                   completion: completion)
    }
    
    func fetchUpcomingVideoWorks(completion: @escaping ResultHandler<[MovieReviewElement]>) {
        repository.fetchUpcomingVideoWorks(completion: completion)
    }
    
}
