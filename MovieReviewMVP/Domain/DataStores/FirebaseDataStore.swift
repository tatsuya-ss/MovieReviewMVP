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
    
    let docRef = Firestore.firestore().collection("movieReview")
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
            "review": movie.review ?? "",
            "create_at": Timestamp(date:movie.create_at ?? Date()),
            "id": movie.id,
            "isStoredAsReview": movie.isStoredAsReview ?? true,
            "media_type": movie.media_type
        ]
        
        docRef.document("\(movie.id)\(movie.media_type ?? "no_media_type")").setData(dataToSave) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Data has been saved!")
            }
        }
    }
}
