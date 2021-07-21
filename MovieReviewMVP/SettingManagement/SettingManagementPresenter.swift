//
//  SettingManagementPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/21.
//

import Foundation


protocol SettingManagementPresenterInput {
    
}

protocol SettingManagementPresenterOutput: AnyObject {
    
}

final class SettingManagementPresenter : SettingManagementPresenterInput {
    
    private weak var view: SettingManagementPresenterOutput!
    private var model: SettingManagementModelInput
    
    init(view: SettingManagementPresenterOutput, model: SettingManagementModelInput) {
        self.view = view
        self.model = model
    }
    
}
