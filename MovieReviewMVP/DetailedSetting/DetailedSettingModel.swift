//
//  DetailedSettingModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/26.
//

import Foundation

protocol DetailedSettingModelInput {
    func fetchUserInfomations() -> String?
}

final class DetailedSettingModel : DetailedSettingModelInput {
    
    let useCase = ReviewUseCase()
    
    func fetchUserInfomations() -> String? {
        useCase.returnCurrentUserEmail()
    }
}
