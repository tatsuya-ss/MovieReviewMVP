//
//  InstructionsViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/08/27.
//

import UIKit

final class InstructionsViewController: UIPageViewController {
    
    private var controllers = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
    }
    
    @IBAction private func stopButtonDidTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension InstructionsViewController {
    
    private func setupPageViewController() {
        let searchInstructionVC = storyboard?.instantiateViewController(
            withIdentifier: "SearchInstructionViewController") as! SearchInstructionViewController
        let reviewInstructionVC = storyboard?.instantiateViewController(
            withIdentifier: "ReviewInstructionViewController") as! ReviewInstructionViewController
        let reviewManagementInstructionVC = storyboard?.instantiateViewController(
            withIdentifier: "ReviewManagementInstructionViewController") as! ReviewManagementInstructionViewController
        let stockInstructionVC = storyboard?.instantiateViewController(
            withIdentifier: "StockInstructionViewController") as! StockInstructionViewController
        let editReviewInstructionVC = storyboard?.instantiateViewController(
            withIdentifier: "EditReviewInstructionViewController") as! EditReviewInstructionViewController
        controllers = [searchInstructionVC,
                       reviewInstructionVC,
                       reviewManagementInstructionVC,
                       stockInstructionVC,
                       editReviewInstructionVC]
        self.dataSource = self
        setViewControllers([controllers[0]],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
    
    static func instantiate() -> UINavigationController {
        let instructionsVC = UIStoryboard(name: "Instructions", bundle: nil).instantiateInitialViewController() as! UINavigationController
        return instructionsVC
    }

}

extension InstructionsViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        controllers.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController),
           index > 0 {
            return controllers[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController),
           index < controllers.count - 1 {
            return controllers[index + 1]
        }
        return nil
    }
    
}
