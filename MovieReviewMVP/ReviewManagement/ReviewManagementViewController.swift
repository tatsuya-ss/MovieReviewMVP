//
//  ReviewManagementViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/09.
//

import UIKit

class ReviewManagementViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var presenter: ReviewManagementPresenterInput!
    func inject(presenter: ReviewManagementPresenterInput) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        presenter.returnReviewContent()
    }
    
    func setup() {
        tableView.register(UINib(nibName: "ReviewManagementTableViewCell", bundle: nil), forCellReuseIdentifier: ReviewManagementTableViewCell.reuseCellIdentifier)
    }
}

extension ReviewManagementViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
}

extension ReviewManagementViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewManagementTableViewCell.reuseCellIdentifier, for: indexPath) as! ReviewManagementTableViewCell
        
        if let movieReview = presenter.movieReview(forRow: indexPath.row) {
            cell.configure(movieReview: movieReview)
        }
        
        return cell
    }
    
}




extension ReviewManagementViewController : ReviewManagementPresenterOutput {
    func updataMovieReview() {
        tableView.reloadData()
    }
    
    
}
