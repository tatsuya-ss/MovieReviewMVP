//
//  SettingManagementModel.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/21.
//

import Foundation

protocol SettingManagementModelInput {
    func returnProfileInfomations() -> (String?, URL?)
}

final class SettingManagementModel : SettingManagementModelInput {
    
    let reviewUseCase = ReviewUseCase()
    
    func returnProfileInfomations() -> (String?, URL?) {
        reviewUseCase.returnProfileInfomations()
    }
}
