//
//  MovieTabBarController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/03.
//

import UIKit

class MovieTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTab()
    }

    func setupTab() {
        let firstViewController = UIStoryboard(name: "SearchMovie", bundle: nil).instantiateInitialViewController() as! SearchMovieViewController
        let firstModel = SearchMovieModel()
        let firstPresenter = SearchMoviePresenter(view: firstViewController, model: firstModel)
        firstViewController.inject(presenter: firstPresenter)
        firstViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
       
        let secondViewController = UIStoryboard(name: "ReviewManagement", bundle: nil).instantiateInitialViewController() as! ReviewManagementViewController
        secondViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        let secondModel = ReviewManagementModel()
        let secondPresenter = ReviewManagementPresenter(view: secondViewController, model: secondModel)
        secondViewController.inject(presenter: secondPresenter)
        
        
        
        var viewControllers = [UIViewController]()
        viewControllers = [firstViewController, secondViewController]
        
//        self.viewControllers = viewControllers.map { UINavigationController(rootViewController: $0)}
        self.setViewControllers(viewControllers, animated: false)
    }
}
