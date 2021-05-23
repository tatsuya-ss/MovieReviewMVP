//
//  SearchMovieModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

protocol SearchMovieModelInput {
    func fetchMovie(fetchState: FetchMovieState, query: String?, completion: @escaping (Result<[MovieReviewElement], SearchError>) -> Void)
}

final class SearchMovieModel : SearchMovieModelInput {
    
    func fetchMovie(fetchState: FetchMovieState, query: String?, completion: @escaping (Result<[MovieReviewElement], SearchError>) -> Void) {
        
        var url: String?
        switch fetchState {
        case .search:
            guard let query = query else { return }
            url = TMDBApi(query: query).searchURL
        case .upcoming:
            url = TMDBUpcomingMovieURL().upcomingMovieURL
        }
        
        guard let fetchUrl = url,
              let encodingUrlString = fetchUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodeUrl = URL(string: encodingUrlString) else { return }
        let urlRequest = URLRequest(url: encodeUrl)
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
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
                    let data: TMDBSearchResponses = try JSONDecoder().decode(TMDBSearchResponses.self, from: data)
                                        
                    var movieSearchResponses: [MovieReviewElement] = []
                    
                    // CodableのmovieInfomation型から共通で使いたいMovieReviewElement型に変換
                    for review in data.results {
                        movieSearchResponses.append(MovieReviewElement(movieInfomation: review))
                    }
                    completion(.success(movieSearchResponses))
                }
                
            } catch {
                print(error)
            }
        })
        task.resume()
    }
}

private extension MovieReviewElement {
    init(movieInfomation: MovieInfomation) {
        self = MovieReviewElement(title: movieInfomation.title,
                                  poster_path: movieInfomation.poster_path,
                                  original_name: movieInfomation.original_name,
                                  backdrop_path: movieInfomation.backdrop_path,
                                  overview: movieInfomation.overview,
                                  releaseDay: movieInfomation.release_date,
                                  reviewStars: nil,
                                  review: nil)
    }
}

//private extension SearchError {
//    init(error: TMDBSearchError) {
//        switch error {
//        case let .TMDBrequestError(error):
//            self = .requestError(error)
//        case .TMDBresponseError:
//            self = .responseError
//        }
//    }
//}
