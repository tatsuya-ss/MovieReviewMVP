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
        let model = SearchMovieModel()
        let presenter = SearchMoviePresenter(view: firstViewController, model: model)
        firstViewController.inject(presenter: presenter)

        
        firstViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        
        var viewControllers = [UIViewController]()
        viewControllers = [firstViewController]
        
//        self.viewControllers = viewControllers.map { UINavigationController(rootViewController: $0)}
        self.setViewControllers(viewControllers, animated: false)
    }
}
