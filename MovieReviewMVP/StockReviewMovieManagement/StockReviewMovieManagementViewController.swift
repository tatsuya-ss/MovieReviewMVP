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
    private var stopButton: UIBarButtonItem!
    private var sortButton: UIBarButtonItem!
    private var editButton: UIBarButtonItem!
    private var trashButton: UIButton!

    
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
        // MARK: navigationBarを透明にする
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        // MARK: キャンセルボタン
        stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
        navigationItem.leftBarButtonItem = stopButton
        // MARK: 編集ボタン
        editButton = editButtonItem
        // MARK: 並び替えボタン
        sortButton = UIBarButtonItem(title: presenter.returnSortState().buttonTitle, image: nil, primaryAction: nil, menu: contextMenuActions())
        [stopButton, editButton, sortButton].forEach { $0.tintColor = .stringColor }
        navigationItem.rightBarButtonItems = [editButton, sortButton]

    }
    
    func contextMenuActions() -> UIMenu {
        let createdDescendAction = UIAction(title: sortState.createdDescend.title, image: nil, state: .off, handler: { _ in
            self.presenter.didTapSortButton(.createdDescend)
            self.sortButton.title = self.presenter.returnSortState().buttonTitle
            print("\(sortState.createdDescend.title)に並び替えました。")
        })
        
        let createdAscendAction = UIAction(title: sortState.createdAscend.title, image: nil, state: .off, handler: { _ in
            self.presenter.didTapSortButton(.createdAscend)
            self.sortButton.title = self.presenter.returnSortState().buttonTitle
            print("\(sortState.createdAscend.title)に並び替えました。")
        })
        
        let reviewStarAscendAction = UIAction(title: sortState.reviewStarAscend.title, image: nil, state: .off, handler: { _ in
            self.presenter.didTapSortButton(.reviewStarAscend)
            self.sortButton.title = self.presenter.returnSortState().buttonTitle
            print("\(sortState.reviewStarAscend.title)に並び替えました。")
        })
        
        let reviewStarDescendAction = UIAction(title: sortState.reviewStarDescend.title, image: nil, state: .off, handler: { _ in
            self.presenter.didTapSortButton(.reviewStarDescend)
            self.sortButton.title = self.presenter.returnSortState().buttonTitle
            print("\(sortState.reviewStarDescend.title)に並び替えました。")
        })
        
        let menu = UIMenu(children: [createdDescendAction, createdAscendAction, reviewStarAscendAction, reviewStarDescendAction])
        
        return menu

    }
    
    @objc func stopButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
    func sortReview() {
        if presenter.numberOfStockMovies > 1 {
            for index in 0...presenter.numberOfStockMovies - 1 {
                stockCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }

    }
    
    
}
