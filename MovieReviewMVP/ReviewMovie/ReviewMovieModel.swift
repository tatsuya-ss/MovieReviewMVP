//
//  ReviewMovieModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMovieModelInput {
    func reviewMovie(movieReviewState: MovieReviewStoreState, _ movie: MovieReviewElement)
    func fetchMovie(sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void)
    func requestMovieDetail(completion: @escaping (Result<Credits, SearchError>) -> Void)
}

final class ReviewMovieModel : ReviewMovieModelInput {
    
    private var movieReviewElement: MovieReviewElement?
    init(movie: MovieReviewElement?, movieReviewElement: MovieReviewElement?) {
        self.movieReviewElement = movie
    }
    
    let reviewUseCase = ReviewUseCase()
    
    func requestMovieDetail(completion: @escaping (Result<Credits, SearchError>) -> Void) {
        guard let movie = movieReviewElement,
              let encodingUrlString = TMDBDetailURL(id: movie.id, mediaType: movie.media_type ?? "movie").detailURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodeUrl = URL(string: encodingUrlString) else { return }
        let urlRequest = URLRequest(url: encodeUrl)

        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            do {
                if let error = error {
                    completion(.failure(.requestError(error)))
                }
                guard let data = data,
                      let response = response as? HTTPURLResponse else {
                    completion(.failure(.responseError))
                    return
                }
                
                if response.statusCode == 200 {
                    let data: TMDBCredits = try JSONDecoder().decode(TMDBCredits.self, from: data)
                    
                    var castDetail: [CastDetail] = []
                    for detail in data.cast {
                        castDetail.append(CastDetail(cast: detail))
                    }
                    
                    var crewDetail: [CrewDetail] = []
                    for detail in data.crew {
                        crewDetail.append(CrewDetail(crew: detail))
                    }

                    let credits: Credits = Credits(cast: castDetail, crew: crewDetail)
                    print(credits)
                    completion(.success(credits))
                }
            } catch {
                print(error)
            }
        }
        task.resume()
        
    }
    
    func reviewMovie(movieReviewState: MovieReviewStoreState, _ movie: MovieReviewElement) {
        switch movieReviewState {
        case .beforeStore:
            reviewUseCase.save(movie: movie)
        case .afterStore:
            reviewUseCase.update(movie: movie)
        }
        
    }
    
    func fetchMovie(sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        reviewUseCase.fetch(isStoredAsReview: nil, sortState: sortState) { result in
            switch result {
            case .success(let reviews):
                completion(.success(reviews))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


private extension CastDetail {
    init(cast: TMDBCastDetail) {
        self = CastDetail(id: cast.id,
                          profile_path: cast.profile_path, name: cast.name)
    }
}

private extension CrewDetail {
    init(crew: TMDBCrewDetail) {
        self = CrewDetail(id: crew.id,
                          profile_path: crew.profile_path,
                          job: crew.job, name: crew.name)
    }
}
