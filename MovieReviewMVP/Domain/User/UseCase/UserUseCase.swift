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
    func deleteAuth(completion: @escaping (Result<Any?, Error>) -> Void)
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
    
    func deleteAuth(completion: @escaping (Result<Any?, Error>) -> Void) {
        repository.deleteAuth(completion: completion)
    }
    
}
