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
    case notLoginError
}

protocol ReviewDataStoreProtocol {
    func checkSaved(movie: VideoWork, completion: @escaping (Bool) -> Void)
    func save(movie: VideoWork, completion: @escaping (Result<(), Error>) -> Void)
    func fetch(isStoredAsReview: Bool?,
               sortState: sortState,
               completion: @escaping (Result<[[String: Any]], Error>) -> Void)
    func sort(isStoredAsReview: Bool,
              sortState: sortState,
              completion: @escaping (Result<[[String: Any]], Error>) -> Void)
    func delete(movie: VideoWork)
    func update(movie: VideoWork)
}

final class ReviewDataStore : ReviewDataStoreProtocol {
    
    let db = Firestore.firestore()
    
    let collectionReference = Firestore.firestore().collection("movieReview")
    
    func checkSaved(movie: VideoWork, completion: @escaping (Bool) -> Void) {
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
    
    func save(movie: VideoWork, completion: @escaping (Result<(), Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let dataToSave: [String: Any] = [
            "title": movie.title ?? "",
            "poster_path": movie.posterPath ?? "",
            "original_name": movie.originalName ?? "",
            "backdrop_path": movie.backdropPath ?? "",
            "overview": movie.overview ?? "",
            "releaseDay": movie.releaseDay ?? "",
            "reviewStars": movie.reviewStars ?? 0.0,
            "review": movie.review,
            "create_at": Timestamp(date: movie.createAt ?? Date()),
            "id": movie.id,
            "isStoredAsReview": movie.isStoredAsReview ?? true,
            "media_type": movie.mediaType
        ]
        
        let documentTitle = makeDocumentTitle(movie: movie)
        db.collection("users").document(uid)
            .collection("reviews").document("\(movie.id)\(documentTitle)")
            .setData(dataToSave) { error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            } else {
                print("\(documentTitle)を保存しました!")
                completion(.success(()))
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
    
    
    func delete(movie: VideoWork) {
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
    
    func update(movie: VideoWork) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let documentTitle = makeDocumentTitle(movie: movie)
        db.collection("users").document(uid).collection("reviews").document("\(movie.id)\(documentTitle)").updateData([
            "title": movie.title ?? "",
            "poster_path": movie.posterPath ?? "",
            "original_name": movie.originalName ?? "",
            "backdrop_path": movie.backdropPath ?? "",
            "overview": movie.overview ?? "",
            "releaseDay": movie.releaseDay ?? "",
            "reviewStars": movie.reviewStars ?? 0.0,
            "review": movie.review,
            "create_at": movie.createAt ?? Date(),
            "id": movie.id,
            "isStoredAsReview": movie.isStoredAsReview ?? true,
            "media_type": movie.mediaType
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("update!")
            }
        }
    }
    
    private func makeDocumentTitle(movie: VideoWork) -> String {
        if let title = movie.title {
            let replacingTitle = title.contains("/")
            ? title.replacingOccurrences(of: "/", with: "／")
            : title
            return replacingTitle
        } else if let originalName = movie.originalName {
            let replacingTitle = originalName.contains("/")
            ? originalName.replacingOccurrences(of: "/", with: "／")
            : originalName
            return replacingTitle
        } else {
            return "タイトルなし"
        }
    }
}
