//
//  SettingManagementPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/21.
//

import Foundation


protocol SettingManagementPresenterInput {
    var numberOfTitles: Int { get }
    func returnCellTitle(indexPath: IndexPath) -> String
    func returnProfileInfomations() -> (String?, URL?)
}

protocol SettingManagementPresenterOutput: AnyObject {
    
}

final class SettingManagementPresenter : SettingManagementPresenterInput {
    
    private weak var view: SettingManagementPresenterOutput!
    private var model: SettingManagementModelInput
    
    let cellTitles = [
        "アカウント情報",
        "操作方法",
        "TMDBについて"
    ]
    
    init(view: SettingManagementPresenterOutput, model: SettingManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    var numberOfTitles: Int { cellTitles.count }
    
    func returnCellTitle(indexPath: IndexPath) -> String {
        cellTitles[indexPath.row]
    }
    
    func returnProfileInfomations() -> (String?, URL?) {
        model.returnProfileInfomations()
    }
}
