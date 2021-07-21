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
        setupNavigation()
    }
    

}

extension SettingManagementViewController {
    
    func setupPresenter() {
        let settingManagementModel = SettingManagementModel()
        let settingManagementPresenter = SettingManagementPresenter(view: self, model: settingManagementModel)
        inject(presenter: settingManagementPresenter)
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: setNavigationTitleLeft(title: "設定"))
        
        func setNavigationTitleLeft(title: String) -> UILabel {
            let label = UILabel()
            label.textColor = UIColor.white
            label.text = title
            label.font = UIFont.boldSystemFont(ofSize: 26)
            
            return label
        }

    }
}

extension SettingManagementViewController : SettingManagementPresenterOutput {
    
}
