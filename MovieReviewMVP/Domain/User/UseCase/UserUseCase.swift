//
//  UserUseCase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/10/12.
//

import Foundation

protocol UserUseCaseProtocol {
    func returnProfileInfomations() -> (String?, URL?)
    func logout()
    func returnCurrentUserEmail() -> String?
    func returnloginStatus() -> Bool
}

final class UserUseCase: UserUseCaseProtocol {
    
    private let repository: UserRepositoryProtocol
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func returnProfileInfomations() -> (String?, URL?) {
        repository.returnProfileInfomations()
    }
    
    func logout() {
        repository.logout()
    }
    
    func returnCurrentUserEmail() -> String? {
        repository.returnCurrentUserEmail()
    }
    
    func returnloginStatus() -> Bool {
        repository.returnloginStatus()
    }
    
}
