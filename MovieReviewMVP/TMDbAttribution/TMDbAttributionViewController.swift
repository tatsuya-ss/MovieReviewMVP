//
//  TMDbAttributionViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/07/25.
//

import UIKit

class TMDbAttributionViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.image = UIImage(named: "tmdb_logo")

        // Do any additional setup after loading the view.
    }

}

//"本製品はTMDbAPIを使用していますが、TMDbによって保証または認定されているものではありません。"
