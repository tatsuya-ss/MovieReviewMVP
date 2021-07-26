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
    func returnHeaderItems() -> [String]
    func didSelectRow(indexPath: IndexPath)
    func logout()
}

protocol DetailedSettingPresenterOutput : AnyObject {
    func displayLogoutAlert()
    func didLogout()
}

final class DetailedSettingPresenter : DetailedSettingPresenterInput {
    
    var userInfomations = [
        [UserInfoMation(item: "メールアドレス", infomation: nil)],
        [UserInfoMation(item: "ログアウトする", infomation: nil)]
    ]
    
    var headerItems = [
        "ユーザー情報",
        "ログイン"
    ]
    
    private weak var view: DetailedSettingPresenterOutput!
    private var model: DetailedSettingModelInput
    private let notificationCenter = NotificationCenter()
    init(view: DetailedSettingPresenterOutput, model: DetailedSettingModelInput) {
        self.view = view
        self.model = model
    }
    
    var numberOfSections: Int { userInfomations.count }
    
    func returnUserInfomations() -> [[UserInfoMation]] {
        let email = model.fetchUserInfomations()
        userInfomations[0][0].infomation = email
        
        let isLogin = model.returnloginStatus()
        switch isLogin {
        case true: userInfomations[1][0].item = "ログアウトする"
        case false: userInfomations[1][0].item = "ログインする"
        }
        return userInfomations
    }
    
    func returnHeaderItems() -> [String] {
        headerItems
    }
    
    func didSelectRow(indexPath: IndexPath) {
        if indexPath == [1, 0] {
            view.displayLogoutAlert()
        }
    }
    
    func logout() {
        model.logout()
        view.didLogout()
        NotificationCenter.default.post(name: .logout, object: nil)
    }
}
