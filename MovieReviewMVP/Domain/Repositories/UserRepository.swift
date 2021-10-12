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
}

final class UserRepository: UserRepositoryProtocol {
    
    private let dataStore: FirebaseDataStoreProtocol
    init(dataStore: FirebaseDataStoreProtocol) {
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
    
}
