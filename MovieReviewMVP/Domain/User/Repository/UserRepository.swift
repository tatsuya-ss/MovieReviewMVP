//
//  UserRepository.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/12.
//

import Foundation

protocol UserRepositoryProtocol {
    func returnProfileInfomations() -> (String?, URL?)
    func logout()
    func returnCurrentUserEmail() -> String?
    func returnloginStatus() -> Bool
    func deleteAuth(completion: @escaping (Result<Any?, Error>) -> Void)
}

final class UserRepository: UserRepositoryProtocol {
    
    private let dataStore: UserDataStoreProtocol
    init(dataStore: UserDataStoreProtocol) {
        self.dataStore = dataStore
    }
    
    func returnProfileInfomations() -> (String?, URL?) {
        dataStore.returnProfileInfomations()
    }
    
    func logout() {
        dataStore.logout()
    }
    
    func returnCurrentUserEmail() -> String? {
        dataStore.returnCurrentUserEmail()
    }
    
    func returnloginStatus() -> Bool {
        dataStore.returnloginStatus()
    }
    
    func deleteAuth(completion: @escaping (Result<Any?, Error>) -> Void) {
        dataStore.deleteAuth(completion: completion)
    }
}
