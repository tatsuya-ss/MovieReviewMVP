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
    var textColorType: TextColorType
}

enum TextColorType {
    case nomal
    case warning
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
    func displayLoginView()
}

final class DetailedSettingPresenter : DetailedSettingPresenterInput {
    
    private var userInfomations = [
        [UserInfoMation(item: "メールアドレス", infomation: nil, textColorType: .nomal)],
        [UserInfoMation(item: "ログアウトする", infomation: nil, textColorType: .nomal),
         UserInfoMation(item: "アカウントを削除する", infomation: nil, textColorType: .warning)]
    ]
    
    private var headerItems = [
        "ユーザー情報",
        "ログイン"
    ]
    let userLoginState = UserLoginState()
    
    private weak var view: DetailedSettingPresenterOutput!
    private let userUseCase: UserUseCaseProtocol
//    private var model: DetailedSettingModelInput
    private let notificationCenter = NotificationCenter()
    
    init(view: DetailedSettingPresenterOutput, userUseCase: UserUseCaseProtocol) {
        self.view = view
        self.userUseCase = userUseCase
    }
    
    var numberOfSections: Int { userInfomations.count }
    
    func returnUserInfomations() -> [[UserInfoMation]] {
        let email = userUseCase.returnCurrentUserEmail()
        userInfomations[0][0].infomation = email
        
        let isLogin = userUseCase.returnloginStatus()
        let loginItem = userLoginState.checkIsLogin(isLogin: isLogin)
        userInfomations[1][0].item = loginItem
        return userInfomations
    }
    
    func returnHeaderItems() -> [String] {
        headerItems
    }
    
    func didSelectRow(indexPath: IndexPath) {
        if indexPath == [1, 0] {
            let isLogin = userLoginState.returnLoginState()
            switch isLogin {
            case true: view.displayLogoutAlert()
            case false: view.displayLoginView()
            }
        }
    }
    
    func logout() {
        userUseCase.logout()
        view.didLogout()
        NotificationCenter.default.post(name: .logout, object: nil)
    }
}
