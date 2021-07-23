//
//  SettingManagementViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/21.
//

import UIKit

final class SettingManagementViewController: UIViewController {
    @IBOutlet private weak var SettingManagementTableView: UITableView!
    
    private var presenter: SettingManagementPresenterInput!
    func inject(presenter: SettingManagementPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupNavigation()
        setupTableView()
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
    
    private func setupTableView() {
        SettingManagementTableView.dataSource = self
        SettingManagementTableView.delegate = self
        
        SettingManagementTableView.register(SettingManagementTableViewCell.nib,
                                            forCellReuseIdentifier: SettingManagementTableViewCell.identifier)
        SettingManagementTableView.register(SettingManagementHeaderView.nib,
                                            forHeaderFooterViewReuseIdentifier: SettingManagementHeaderView.identifier)
        
        makeFooter()
    }
}

extension SettingManagementViewController {
    private func makeFooter() {
        let footerView = UIView()
        footerView.backgroundColor = .black
        footerView.frame.size.height = 100
        self.SettingManagementTableView.tableFooterView = footerView
        
        let label = UILabel()
        footerView.addSubview(label)
        label.text = "バージョン1.0"
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        [label.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
         label.centerXAnchor.constraint(equalTo: footerView.centerXAnchor)]
            .forEach { $0.isActive = true }
    }
    
    
}

extension SettingManagementViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfTitles
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingManagementTableView.dequeueReusableCell(withIdentifier: SettingManagementTableViewCell.identifier, for: indexPath) as! SettingManagementTableViewCell
        
        let title = presenter.returnCellTitle(indexPath: indexPath)
        cell.configure(title: title)
        
        return cell
    }
}

extension SettingManagementViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SettingManagementTableView.dequeueReusableHeaderFooterView(withIdentifier: SettingManagementHeaderView.identifier) as! SettingManagementHeaderView
        let userInfomations = presenter.returnProfileInfomations()
        header.configure(userInfomation: userInfomations)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        SettingManagementTableView.bounds.height / 5
    }
    
}

extension SettingManagementViewController : SettingManagementPresenterOutput {
    
}
