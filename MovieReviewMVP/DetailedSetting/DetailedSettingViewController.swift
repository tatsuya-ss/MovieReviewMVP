//
//  DetailedSettingViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/25.
//

import UIKit

final class DetailedSettingViewController: UIViewController {
    @IBOutlet weak var userDetailsTableView: UITableView!
    
    private var presenter: DetailedSettingPresenterInput!
    func inject(presenter: DetailedSettingPresenterInput) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
    }

}

extension DetailedSettingViewController {
    
    private func setupPresenter() {
        let detailedSettingModel = DetailedSettingModel()
        let detailedSettingPresenter = DetailedSettingPresenter(view: self, model: detailedSettingModel)
        inject(presenter: detailedSettingPresenter)
    }
}

extension DetailedSettingViewController : DetailedSettingPresenterOutput {
    
}
