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

enum FirebaseError: Error {
    case fetchError
}

protocol ReviewDataStoreProtocol {
    func checkSaved(movie: MovieReviewElement, completion: @escaping (Bool) -> Void)
    func save(movie: MovieReviewElement)
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[[String: Any]], Error>) -> Void)
    func sort(isStoredAsReview: Bool,
              sortState: sortState,
              completion: @escaping (Result<[[String: Any]], Error>) -> Void)
    func delete(movie: MovieReviewElement)
    func update(movie: MovieReviewElement)
}

final class ReviewDataStore : ReviewDataStoreProtocol {
    
    let db = Firestore.firestore()
    
    let collectionReference = Firestore.firestore().collection("movieReview")
    var movieReviews = [MovieReviewElement]()
    
    func checkSaved(movie: MovieReviewElement, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let documentTitle = makeDocumentTitle(movie: movie)
        db.collection("users").document(uid)
            .collection("reviews").document("\(movie.id)\(documentTitle)")
            .getDocument { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot,
                  documentSnapshot.exists
            else { completion(false)
                return }
            completion(true)
        }
        
    }
    
    func save(movie: MovieReviewElement) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
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
        
        let documentTitle = makeDocumentTitle(movie: movie)
        db.collection("users").document(uid)
            .collection("reviews").document("\(movie.id)\(documentTitle)")
            .setData(dataToSave) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("\(documentTitle)を保存しました!")
            }
        }
    }
    
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        if let isStoredAsReview = isStoredAsReview {
            db.collection("users").document(uid).collection("reviews")
                .whereField("isStoredAsReview", isEqualTo: isStoredAsReview)
                .order(by: "create_at", descending: sortState.Descending)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        guard let querySnapshot = querySnapshot
                        else { completion(.failure(FirebaseError.fetchError))
                            return }
                        let data = querySnapshot.documents.map {
                            $0.data()
                        }
                        completion(.success(data))
                    }
                }
        } else {
            db.collection("users").document(uid).collection("reviews")
                .order(by: "create_at", descending: sortState.Descending)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        guard let querySnapshot = querySnapshot
                        else { completion(.failure(FirebaseError.fetchError))
                            return }
                        let data = querySnapshot.documents.map { $0.data() }
                        completion(.success(data))
                    }
                }
        }
        
    }
    
    func sort(isStoredAsReview: Bool, sortState: sortState, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        db.collection("users").document(uid).collection("reviews")
            .whereField("isStoredAsReview", isEqualTo: isStoredAsReview)
            .order(by: sortState.keyPath, descending: sortState.Descending)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    guard let querySnapshot = querySnapshot
                    else { completion(.failure(FirebaseError.fetchError))
                        return }
                    let data = querySnapshot.documents.map { $0.data() }
                    completion(.success(data))
                }
            }
    }
    
    
    func delete(movie: MovieReviewElement) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let documentTitle = makeDocumentTitle(movie: movie)
        db.collection("users").document(uid).collection("reviews").document("\(movie.id)\(documentTitle)").delete() { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("削除しました")
            }
        }
    }
    
    func update(movie: MovieReviewElement) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let documentTitle = makeDocumentTitle(movie: movie)
        db.collection("users").document(uid).collection("reviews").document("\(movie.id)\(documentTitle)").updateData([
            "title": movie.title ?? "",
            "poster_path": movie.poster_path ?? "",
            "original_name": movie.original_name ?? "",
            "backdrop_path": movie.backdrop_path ?? "",
            "overview": movie.overview ?? "",
            "releaseDay": movie.releaseDay ?? "",
            "reviewStars": movie.reviewStars ?? 0.0,
            "review": movie.review,
            "create_at": movie.create_at ?? Date(),
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
    
    private func makeDocumentTitle(movie: MovieReviewElement) -> String {
        if let title = movie.title {
            let replacingTitle = title.contains("/")
            ? title.replacingOccurrences(of: "/", with: "／")
            : title
            return replacingTitle
        } else if let originalName = movie.original_name {
            let replacingTitle = originalName.contains("/")
            ? originalName.replacingOccurrences(of: "/", with: "／")
            : originalName
            return replacingTitle
        } else {
            return "タイトルなし"
        }
    }
}