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
import FirebaseUI

struct UserError: Error {
    var errorMessage: String {
        return "ユーザーIDがありません"
    }
}

struct UserDefault {
    func getUserId() -> String {
        guard let uid = UserDefaults.standard.string(forKey: "userId") else { fatalError(UserError().errorMessage) }
        return uid
    }
}


final class Firebase : ReviewRepository {
    
    let db = Firestore.firestore()
    let userDefault = UserDefault()
    
    let collectionReference = Firestore.firestore().collection("movieReview")
    var movieReviews = [MovieReviewElement]()
    
    func checkSaved(movie: MovieReviewElement, completion: @escaping (Bool) -> Void) {
        let uid = userDefault.getUserId()
        db.collection("users").document(uid).collection("reviews").document("\(movie.id)\(movie.media_type ?? "no_media_type")").getDocument { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot,
                  documentSnapshot.exists else { completion(false) ; return }
            completion(true)
        }
        
    }
    
    func save(movie: MovieReviewElement) {
        let uid = userDefault.getUserId()
            let dataToSave: [String: Any] = [
                "title": movie.title ?? "",
                "poster_path": movie.poster_path ?? "",
                "original_name": movie.original_name ?? "",
                "backdrop_path": movie.backdrop_path ?? "",
                "overview": movie.overview ?? "",
                "releaseDay": movie.releaseDay ?? "",
                "reviewStars": movie.reviewStars ?? 0.0,
                "review": movie.review,
                "create_at": Timestamp(date: movie.create_at ?? Date()),
                "id": movie.id,
                "isStoredAsReview": movie.isStoredAsReview ?? true,
                "media_type": movie.media_type
            ]
            
        db.collection("users").document(uid).collection("reviews").document("\(movie.id)\(movie.media_type ?? "no_media_type")").setData(dataToSave) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Data has been saved!")
                }
            }
    }
    
    func fetch(isStoredAsReview: Bool?, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        let uid = userDefault.getUserId()
        if let isStoredAsReview = isStoredAsReview {
            db.collection("users").document(uid).collection("reviews")
                .whereField("isStoredAsReview", isEqualTo: isStoredAsReview)
                .order(by: "create_at", descending: sortState.Descending)
                .getDocuments { querySnapshot, error in
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
        } else {
            db.collection("users").document(uid).collection("reviews")
                .order(by: "create_at", descending: sortState.Descending)
                .getDocuments { querySnapshot, error in
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
    
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[MovieReviewElement], Error>) -> Void) {
        let uid = userDefault.getUserId()
        db.collection("users").document(uid).collection("reviews")
            .whereField("isStoredAsReview", isEqualTo: isStoredAsReview)
            .order(by: sortState.keyPath, descending: sortState.Descending)
            .getDocuments { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.movieReviews.removeAll()
                for document in querySnapshot!.documents {
                    self.movieReviews.append(MovieReviewElement(document: document))
                }
                completion(.success(self.movieReviews))
            }
        }
    }

    
    func delete(movie: MovieReviewElement) {
        let uid = userDefault.getUserId()
        db.collection("users").document(uid).collection("reviews").document("\(movie.id)\(movie.media_type ?? "no_media_type")").delete() { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("削除しました")
            }
        }
    }
    
    func update(movie: MovieReviewElement) {
        let uid = userDefault.getUserId()
        db.collection("users").document(uid).collection("reviews").document("\(movie.id)\(movie.media_type ?? "no_media_type")").updateData([
            "title": movie.title ?? "",
            "poster_path": movie.poster_path ?? "",
            "original_name": movie.original_name ?? "",
            "backdrop_path": movie.backdrop_path ?? "",
            "overview": movie.overview ?? "",
            "releaseDay": movie.releaseDay ?? "",
            "reviewStars": movie.reviewStars ?? 0.0,
            "review": movie.review,
//            "create_at": movie.create_at ?? Date(),
            "id": movie.id,
            "isStoredAsReview": movie.isStoredAsReview ?? true,
            "media_type": movie.media_type
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("update!")
            }
        }
    }
    
    func returnProfileInfomations() -> (String?, URL?) {
        guard let user = Auth.auth().currentUser else { return (nil, nil) }
            let name = user.displayName
            let photoURL = user.photoURL
        return (name, photoURL)
    }

}

private extension MovieReviewElement {
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        let timestamp = data["create_at"] as? Timestamp
        self = MovieReviewElement(title: data["title"] as? String ?? "",
                                  poster_path: data["poster_path"] as? String ?? "",
                                  original_name: data["original_name"] as? String ?? "",
                                  backdrop_path: data["backdrop_path"] as? String ?? "",
                                  overview: data["overview"] as? String ?? "",
                                  releaseDay: data["releaseDay"] as? String ?? "",
                                  reviewStars: data["reviewStars"] as? Double ?? 0.0,
                                  review: data["review"] as? String ?? "",
                                  create_at: timestamp?.dateValue(),
                                  id: data["id"] as? Int ?? 0,
                                  isStoredAsReview: data["isStoredAsReview"] as? Bool,
                                  media_type: data["media_type"] as? String)
    }
}
