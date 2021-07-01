//
//  ReviewMovieModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/30.
//

import Foundation

protocol ReviewMovieModelInput {
    func reviewMovie(movieReviewState: MovieReviewStoreState, _ movie: MovieReviewElement)
    func fetchMovie(sortState: sortState) -> [MovieReviewElement]
    func requestMovieDetail(completion: @escaping (Result<Credits, SearchError>) -> Void)
//    func requestPersonDetail(castDetail: CastDetail, completion: @escaping (Result<Person, SearchError>) -> Void)
}

final class ReviewMovieModel : ReviewMovieModelInput {
    
    private var movieReviewElement: MovieReviewElement?
    init(movie: MovieReviewElement?, movieReviewElement: MovieReviewElement?) {
        self.movieReviewElement = movie
    }
    
    let movieUseCase = MovieUseCase()
    
    func requestMovieDetail(completion: @escaping (Result<Credits, SearchError>) -> Void) {
        guard let movie = movieReviewElement,
              let encodingUrlString = TMDBDetailURL(id: movie.id).detailURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
                    completion(.success(credits))
                }
            } catch {
                print(error)
            }
        }
        task.resume()
        
    }
    
//    func requestPersonDetail(castDetail: CastDetail, completion: @escaping (Result<Person, SearchError>) -> Void) {
//        guard let id = castDetail.id,
//              let encodingUrlString = TMDBPersonURL(id: id).personURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let encodeUrl = URL(string: encodingUrlString) else { return }
//        let urlRequest = URLRequest(url: encodeUrl)
//
//        let task = URLSession.shared.dataTask(with: urlRequest) { (date, response, error) in
//            do {
//                if let error = error {
//                    completion(.failure(.requestError(error)))
//                }
//
//                guard let data = date,
//                      let response = response as? HTTPURLResponse else {
//                    completion(.failure(.responseError))
//                    return
//                }
//
//                if response.statusCode == 200 {
//                    let data: TMDBPerson = try JSONDecoder().decode(TMDBPerson.self, from: data)
//
//                    let personDetail = Person(also_known_as: data.also_known_as)
//                    completion(.success(personDetail))
//                }
//
//            } catch {
//                print(error)
//            }
//        }
//        task.resume()
//    }

    func reviewMovie(movieReviewState: MovieReviewStoreState, _ movie: MovieReviewElement) {
        switch movieReviewState {
        case .beforeStore:
            movieUseCase.create(movie)
        case .afterStore:
            movieUseCase.update(movie)
        }
        
    }
    
    func fetchMovie(sortState: sortState) -> [MovieReviewElement] {
        movieUseCase.fetch(sortState, isStoredAsReview: nil)
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
