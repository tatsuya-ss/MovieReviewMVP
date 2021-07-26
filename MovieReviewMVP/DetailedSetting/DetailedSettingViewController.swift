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
        setupTableView()
    }

}

extension DetailedSettingViewController {
    
    private func setupPresenter() {
        let detailedSettingModel = DetailedSettingModel()
        let detailedSettingPresenter = DetailedSettingPresenter(view: self, model: detailedSettingModel)
        inject(presenter: detailedSettingPresenter)
    }
    
    private func setupTableView() {
        userDetailsTableView.dataSource = self
        userDetailsTableView.register(DetailedSettingTableViewCell.nib, forCellReuseIdentifier: DetailedSettingTableViewCell.identifier)
    }
}

extension DetailedSettingViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userInfomations = presenter.returnUserInfomations()
        return userInfomations[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userDetailsTableView.dequeueReusableCell(withIdentifier: DetailedSettingTableViewCell.identifier, for: indexPath) as! DetailedSettingTableViewCell
        let userInfomations = presenter.returnUserInfomations()
        let userInfomation = userInfomations[indexPath.section][indexPath.row]
        cell.configure(item: userInfomation.item,
                       infomation: userInfomation.infomation)
        
        return cell
    }
    
    
}

extension DetailedSettingViewController : DetailedSettingPresenterOutput {
    
}
