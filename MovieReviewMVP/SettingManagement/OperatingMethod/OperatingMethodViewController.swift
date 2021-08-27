//
//  OperatingMethodViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/08/19.
//

import UIKit

final class OperatingMethodViewController: UIViewController {
    
    @IBOutlet private weak var operatingMethodTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTextView()
    }
    
    static func instantiate() -> OperatingMethodViewController {
        let operatingMethodVC = UIStoryboard(name: "OperatingMethod", bundle: nil).instantiateInitialViewController() as! OperatingMethodViewController
        return operatingMethodVC
    }

}

extension OperatingMethodViewController {
    private func setupNavigation() {
        let backButton = UIBarButtonItem()
        backButton.title = .setting
        backButton.tintColor = .stringColor
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func setupTextView() {
        operatingMethodTextView.isEditable = false
        operatingMethodTextView.isSelectable = false
    }

}
