//
//  DetailedSettingPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/26.
//

import Foundation

struct UserInfoMation {
    var item: String
    var infomation: String?
}

protocol DetailedSettingPresenterInput {
    var numberOfSections: Int { get }
    func returnUserInfomations() -> [[UserInfoMation]]
}

protocol DetailedSettingPresenterOutput : AnyObject {
    
}

final class DetailedSettingPresenter : DetailedSettingPresenterInput {
    
    var userInfomations = [
        [UserInfoMation(item: "メールアドレス", infomation: nil)],
        [UserInfoMation(item: "ログアウト", infomation: nil)]
    ]
    
    private weak var view: DetailedSettingPresenterOutput!
    private var model: DetailedSettingModelInput
    init(view: DetailedSettingPresenterOutput, model: DetailedSettingModelInput) {
        self.view = view
        self.model = model
    }
    
    var numberOfSections: Int { userInfomations.count }
    
    func returnUserInfomations() -> [[UserInfoMation]] {
        let email = model.fetchUserInfomations()
        userInfomations[0][0].infomation = email
        return userInfomations
    }
    
    
}
