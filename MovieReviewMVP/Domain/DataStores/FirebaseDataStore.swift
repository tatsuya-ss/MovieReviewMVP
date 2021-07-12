//
//  FirebaseDataStore.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/12.
//

import Foundation

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


final class Firebase : ReviewRepository {
    let db = Firestore.firestore()
    
    let collectionReference = Firestore.firestore().collection("movieReview")
    var movieReviews = [MovieReviewElement]()
    
    func save(movie: MovieReviewElement) {
        let dataToSave: [String: Any] = [
            "title": movie.title ?? "",
            "poster_path": movie.poster_path ?? "",
            "original_name": movie.original_name ?? "",
            "backdrop_path": movie.backdrop_path ?? "",
            "overview": movie.overview ?? "",
            "releaseDay": movie.releaseDay ?? "",
            "reviewStars": movie.reviewStars ?? 0.0,
            "review": movie.review,
            "create_at": Timestamp(date:movie.create_at ?? Date()),
            "id": movie.id,
            "isStoredAsReview": movie.isStoredAsReview ?? true,
            "media_type": movie.media_type
        ]
        
        collectionReference.document("\(movie.id)\(movie.media_type ?? "no_media_type")").setData(dataToSave) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Data has been saved!")
            }
        }
    }
    
    func fetch(sortState: sortState, isStoredAsReview: Bool?, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        collectionReference.getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.movieReviews.removeAll()
                for document in querySnapshot!.documents {
                    self.movieReviews.append(MovieReviewElement(document: document))
                }
                completion(.success(self.movieReviews))
            }
        }
    }

}

private extension MovieReviewElement {
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self = MovieReviewElement(title: data["title"] as? String ?? "",
                                  poster_path: data["poster_path"] as? String ?? "",
                                  original_name: data["original_name"] as? String ?? "",
                                  backdrop_path: data["backdrop_path"] as? String ?? "",
                                  overview: data["overview"] as? String ?? "",
                                  releaseDay: data["releaseDay"] as? String ?? "",
                                  reviewStars: data["reviewStars"] as? Double ?? 0.0,
                                  review: data["review"] as? String ?? "",
                                  create_at: data["create_at"] as? Date,
                                  id: data["id"] as? Int ?? 0,
                                  isStoredAsReview: data["isStoredAsReview"] as? Bool,
                                  media_type: data["media_type"] as? String)
    }
}
