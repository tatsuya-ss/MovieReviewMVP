//
//  DetailedSettingPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/26.
//

import Foundation

protocol DetailedSettingPresenterInput {
    
}

protocol DetailedSettingPresenterOutput : AnyObject {
    
}

final class DetailedSettingPresenter : DetailedSettingPresenterInput {
    
    private weak var view: DetailedSettingPresenterOutput!
    private var model: DetailedSettingModelInput
    init(view: DetailedSettingPresenterOutput, model: DetailedSettingModelInput) {
        self.view = view
        self.model = model
    }
}
