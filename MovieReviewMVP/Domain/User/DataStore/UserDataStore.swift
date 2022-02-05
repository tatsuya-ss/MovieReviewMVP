//
//  UserDataStore.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/12.
//

import Foundation
import FirebaseAuth

protocol UserDataStoreProtocol {
    func returnProfileInfomations() -> (String?, URL?)
    func logout()
    func returnCurrentUserEmail() -> String?
    func returnloginStatus() -> Bool
    func deleteAuth(completion: @escaping (Result<Any?, Error>) -> Void)
}

final class UserDataStore: UserDataStoreProtocol {
    
    func returnProfileInfomations() -> (String?, URL?) {
        guard let user = Auth.auth().currentUser else { return (nil, nil) }
        let name = user.displayName
        let photoURL = user.photoURL
        return (name, photoURL)
    }
    
    func returnCurrentUserEmail() -> String? {
        guard let user = Auth.auth().currentUser else { return nil }
        return user.email
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    func returnloginStatus() -> Bool {
        guard let _ = Auth.auth().currentUser else { return false }
        return true
    }
    
    func deleteAuth(completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(FirebaseError.notLoginError))
            return
        }
        user.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
    
}
