//
//  SearchMovieModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import Foundation

protocol SearchMovieModelInput {
    func fetchMovie(query: String, completion: @escaping (Result<MovieSearchResponses, SearchError>) -> Void)

}

final class SearchMovieModel : SearchMovieModelInput {
    
    func fetchMovie(query: String, completion: @escaping (Result<MovieSearchResponses, SearchError>) -> Void) {
        let url = TMDBApi(query: query).searchURL
        guard let encodingUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
                    completion(.success(MovieSearchResponses(response: data)))
                }
                
            } catch {
                print(error)
            }
        })
        task.resume()
    }
}

private extension MovieSearchResponses {
    init(response: TMDBSearchResponses) {
        self = MovieSearchResponses(results: response.results)
    }
}
//
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
