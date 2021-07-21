//
//  SettingManagementViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/21.
//

import UIKit

class SettingManagementViewController: UIViewController {
    
    private var presenter: SettingManagementPresenterInput!
    func inject(presenter: SettingManagementPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
    }
    

}

extension SettingManagementViewController {
    
    func setupPresenter() {
        let settingManagementModel = SettingManagementModel()
        let settingManagementPresenter = SettingManagementPresenter(view: self, model: settingManagementModel)
        inject(presenter: settingManagementPresenter)
    }
}

extension SettingManagementViewController : SettingManagementPresenterOutput {
    
}
