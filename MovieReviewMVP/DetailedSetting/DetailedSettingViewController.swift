//
//  DetailedSettingViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/25.
//

import UIKit
import FirebaseUI

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
        setupNavigation()
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
        userDetailsTableView.delegate = self
        userDetailsTableView.register(DetailedSettingTableViewCell.nib, forCellReuseIdentifier: DetailedSettingTableViewCell.identifier)
        userDetailsTableView.register(DetailedSettingHeaderView.nib, forHeaderFooterViewReuseIdentifier: DetailedSettingHeaderView.identifier)
    }
    
    private func setupNavigation() {
        let backButton = UIBarButtonItem()
        backButton.title = .setting
        backButton.tintColor = .stringColor
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
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
        let textColor: UIColor = userInfomation.textColorType == .warning ? .systemRed : .stringColor
        cell.configure(item: userInfomation.item,
                       infomation: userInfomation.infomation,
                       textColor: textColor)
        
        return cell
    }
}

extension DetailedSettingViewController : UITableViewDelegate {
    // MARK: headerの処理
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = userDetailsTableView.dequeueReusableHeaderFooterView(withIdentifier: DetailedSettingHeaderView.identifier) as! DetailedSettingHeaderView
        let headerItems = presenter.returnHeaderItems()
        header.configure(item: headerItems[section])
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .systemGray
    }
    
    // MARK: cellの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(indexPath: indexPath)
    }
}

extension DetailedSettingViewController : FUIAuthDelegate {
    private func auth() {
        if let authUI = FUIAuth.defaultAuthUI() {
            authUI.providers = [
                FUIOAuth.appleAuthProvider(),
                FUIGoogleAuth(authUI: authUI),
                FUIOAuth.twitterAuthProvider()
            ]
            authUI.delegate = self
            
            let authViewController = authUI.authViewController()
            self.present(authViewController, animated: true)
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            print("\(user.uid)でサインインしました。emailは\(user.email ?? "")です。アカウントは\(user.displayName ?? "")")
            userDetailsTableView.reloadData()
            NotificationCenter.default.post(name: .login, object: nil)
        }
    }
}

extension DetailedSettingViewController : DetailedSettingPresenterOutput {
    func displayLogoutAlert() {
        if let logoutAlert = UIAlertController.makeLogoutAlert(presenter: presenter) {
            present(logoutAlert, animated: true, completion: nil)
        }
    }
    
    func displayLoginView() {
        auth()
    }
    
    func didLogout() {
        userDetailsTableView.reloadData()
    }
}
