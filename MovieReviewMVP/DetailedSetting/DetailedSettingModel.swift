//
//  DetailedSettingModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/26.
//

import Foundation

protocol DetailedSettingModelInput {
    func fetchUserInfomations() -> String?
    func logout()
    func returnloginStatus() -> Bool
}

final class DetailedSettingModel : DetailedSettingModelInput {
    
    let userUseCase = UserUseCase(repository: UserRepository(dataStore: UserDataStore()))

    func fetchUserInfomations() -> String? {
        userUseCase.returnCurrentUserEmail()
    }
    
    func logout() {
        userUseCase.logout()
    }
    
    func returnloginStatus() -> Bool {
        userUseCase.returnloginStatus()
    }
}
