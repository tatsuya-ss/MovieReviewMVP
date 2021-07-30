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
    func didSelectCell(didSelectRowAt indexPath: IndexPath)
    func refresh()
}

protocol SettingManagementPresenterOutput: AnyObject {
    func displayDetailSettingView(indexPath: IndexPath, title: String)
    func displayTMDbAttributionView(indexPath: IndexPath, title: String)
    func didLogout()
}

final class SettingManagementPresenter : SettingManagementPresenterInput {
    
    private weak var view: SettingManagementPresenterOutput!
    private var model: SettingManagementModelInput
    
    let cellTitles = [
        "アカウント情報",
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
    
    func refresh() {
        view.didLogout()
    }
    
    func didSelectCell(didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            view.displayDetailSettingView(indexPath: indexPath, title: cellTitles[indexPath.row])
        case 1:
            view.displayTMDbAttributionView(indexPath: indexPath, title: cellTitles[indexPath.row])
        default:
            break
        }
    }
}
