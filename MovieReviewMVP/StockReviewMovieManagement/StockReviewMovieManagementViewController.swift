//
//  StockReviewMovieManagementViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/16.
//

import UIKit

class StockReviewMovieManagementViewController: UIViewController {
    @IBOutlet var stockCollectionView: UICollectionView!
    private var colunmFlowLayout: UICollectionViewFlowLayout!
    
    private var presenter: StockReviewMovieManagementPresenterInput!
    func inject(presenter: StockReviewMovieManagementPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupCollection()
        presenter.fetchStockMovies()

    }
    
    
    func setupCollection() {
        colunmFlowLayout = StockReviewColumnFlowLayout()
        stockCollectionView.collectionViewLayout = colunmFlowLayout
        stockCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stockCollectionView.alwaysBounceVertical = true
        stockCollectionView.allowsMultipleSelection = true
        stockCollectionView.register(StockReviewMovieCollectionViewCell.nib, forCellWithReuseIdentifier: StockReviewMovieCollectionViewCell.identifier)
        stockCollectionView.dataSource = self
        stockCollectionView.delegate = self

    }
    
    func setupNavigation() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }

}

extension StockReviewMovieManagementViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfStockMovies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = stockCollectionView.dequeueReusableCell(withReuseIdentifier: StockReviewMovieCollectionViewCell.identifier, for: indexPath) as! StockReviewMovieCollectionViewCell
        let stockMovieReview = presenter.returnStockMovieForCell(forRow: indexPath.row)
        cell.configure(movieReview: stockMovieReview)
        
        return cell
    }
    
    
}

extension StockReviewMovieManagementViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        CGFloat(5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // 垂直スクロールの横幅
        CGFloat(5)
    }
}

extension StockReviewMovieManagementViewController : UICollectionViewDelegate {
    
}


extension StockReviewMovieManagementViewController : StockReviewMovieManagementPresenterOutput {
    
}
