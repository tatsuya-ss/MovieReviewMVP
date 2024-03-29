//
//  DetailedSettingViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/25.
//

import UIKit
import FirebaseUI

extension DetailedSettingViewController: UIActivityIndicatorProtocol { }

final class DetailedSettingViewController: UIViewController {
    
    @IBOutlet private weak var userDetailsTableView: UITableView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var presenter: DetailedSettingPresenterInput!
    func inject(presenter: DetailedSettingPresenterInput) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupTableView()
        setupNavigation()
        setupIndicator(indicator: activityIndicatorView)
    }

}

extension DetailedSettingViewController {
    
    private func setupPresenter() {
        let detailedSettingPresenter = DetailedSettingPresenter(
            view: self,
            userUseCase: UserUseCase(repository: UserRepository(
                dataStore: UserDataStore()
            ))
        )
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
        let logoutAlert = UIAlertController(title: "ログアウト", message: "ログアウトしますか？", preferredStyle: .alert)
        logoutAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        logoutAlert.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { [weak self] _ in
            self?.startIndicator(indicator: self?.activityIndicatorView ?? UIActivityIndicatorView())
            self?.presenter.logout()
        }))
        present(logoutAlert, animated: true, completion: nil)
    }
    
    func displayLoginView() {
        auth()
    }
    
    func didLogout() {
        userDetailsTableView.reloadData()
        stopIndicator(indicator: activityIndicatorView)
    }
    
    func displayDeleteAuthAlert() {
        let alert = UIAlertController(title: "アカウントを削除しますか？", message: "この操作は取り消せません。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { [weak self] _ in
            self?.startIndicator(indicator: self?.activityIndicatorView ?? UIActivityIndicatorView())
            self?.presenter.deleteAuth()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func displayNotLoginAlert() {
        stopIndicator(indicator: activityIndicatorView)
        let alert = UIAlertController(title: "ログインされていないため、削除するアカウントがありません", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func displayDeleteAuthResultAlert(title: String, message: String?) {
        userDetailsTableView.reloadData()
        stopIndicator(indicator: activityIndicatorView)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
