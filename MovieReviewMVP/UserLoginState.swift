//
//  UserLoginState.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/27.
//

import Foundation

final class UserLoginState {
    private var isLogin = false
    
    func returnLoginState() -> Bool {
        isLogin
    }
    
    func checkIsLogin(isLogin: Bool) -> String {
        self.isLogin = isLogin
        switch isLogin {
        case true: return "ログアウトする"
        case false: return "ログインする"
        }
    }
    
    
}
