//
//  SettingManagementViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/21.
//

import UIKit
import GoogleMobileAds

final class SettingManagementViewController: UIViewController {
    @IBOutlet private weak var SettingManagementTableView: UITableView!
    private var bannerView: GADBannerView!

    private var presenter: SettingManagementPresenterInput!
    func inject(presenter: SettingManagementPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupNavigation()
        setupTableView()
        setupNotification()
        setupBanner()
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
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: .setNavigationTitleLeft(title: .setting))
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
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refresh),
                                               name: .logout,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refresh),
                                               name: .login,
                                               object: nil)

    }
    
    private func setupBanner() {
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)

        addBannerViewToView(bannerView)

        bannerView.delegate = self
        
        if let id = adUnitID(key: "banner") {
            bannerView.adUnitID = id
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            
            let adSize = GADAdSizeFromCGSize(CGSize(width: view.bounds.width, height: kGADAdSizeLargeBanner.size.height))
            bannerView.adSize = adSize
        }
        
        func adUnitID(key: String) -> String? {
            guard let adUnitIDs = Bundle.main.object(forInfoDictionaryKey: "AdUnitIDs") as? [String: String] else {
                return nil
            }
            return adUnitIDs[key]
        }

    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        [bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         bannerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         bannerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)]
            .forEach { $0.isActive = true }
    }

}

extension SettingManagementViewController {
    @objc func refresh() {
        presenter.refresh()
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
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        label.text = .version + version
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
    // MARK: headerの処理
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SettingManagementTableView.dequeueReusableHeaderFooterView(withIdentifier: SettingManagementHeaderView.identifier) as! SettingManagementHeaderView
        let userInfomations = presenter.returnProfileInfomations()
        let height = SettingManagementTableView.bounds.height / 6
        header.configure(userInfomation: userInfomations, height: height)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        SettingManagementTableView.bounds.height / 6
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .black
    }
    
    // MARK: cellの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectCell(didSelectRowAt: indexPath)
    }
}

extension SettingManagementViewController : SettingManagementPresenterOutput {
    func displayDetailSettingView(indexPath: IndexPath, title: String) {
        let detailedSettingVC = UIStoryboard(name: "DetailedSetting", bundle: nil).instantiateInitialViewController() as! DetailedSettingViewController
        navigationController?.pushViewController(detailedSettingVC, animated: true)
        
    }
    
    func displayTMDbAttributionView(indexPath: IndexPath, title: String) {
        let tmdbAttributionVC = UIStoryboard(name: "TMDbAttribution", bundle: nil).instantiateInitialViewController() as! TMDbAttributionViewController
        navigationController?.pushViewController(tmdbAttributionVC, animated: true)
    }
    
    func displayOperatingMethodView(indexPath: IndexPath, title: String) {
        let operatingMethodVC = OperatingMethodViewController.instantiate()
        navigationController?.pushViewController(operatingMethodVC, animated: true)
    }
    
    func didLogout() {
        SettingManagementTableView.reloadData()
    }
}

extension SettingManagementViewController : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
          bannerView.alpha = 1
        })
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }

}
