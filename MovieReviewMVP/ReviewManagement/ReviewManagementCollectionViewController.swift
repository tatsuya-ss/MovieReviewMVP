//
//  ReviewManagementCollectionViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//

import UIKit

class ReviewManagementCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!    
    private var collectionViewCellWidth: CGFloat?
    let movieUseCase = MovieUseCase()
    
    private var presenter: ReviewManagementPresenterInput!
    func inject(presenter: ReviewManagementPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        collectionView.dataSource = self
        collectionView.delegate = self
        movieUseCase.notification(presenter)
    }
    
}

// MARK: - setup
private extension ReviewManagementCollectionViewController {
    
    func setup() {
        setupPresenter()
        setupNavigation()
        setupTabBar()
        setupCollectionView()
        collectionViewCellLayout()
    }
    
    func setupPresenter() {
        let reviewManagementModel = ReviewManagementModel()
        let reviewManagementPresenter = ReviewManagementPresenter(view: self, model: reviewManagementModel)
        inject(presenter: reviewManagementPresenter)
    }

    func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "マイレビュー"
    }
    
    func setupTabBar() {
        tabBarController?.tabBar.isTranslucent = false
    }
    
    
    func setupCollectionView() {
        collectionView.register(ReviewManagementCollectionViewCell.nib, forCellWithReuseIdentifier: ReviewManagementCollectionViewCell.identifier)
    }

    
    func collectionViewCellLayout() {
        let layout = UICollectionViewFlowLayout()
        
        let safeAreaWidth = view.bounds.width - 20
        let cellWidth = (safeAreaWidth - 10) / 3
        collectionViewCellWidth = cellWidth
        // ここの25は何回もビルドして調整したため、他にいい方法ないか調べる
        let cellHeight = (collectionView.bounds.height - 25) / 4

        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 5
        

        collectionView.collectionViewLayout = layout
        
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension ReviewManagementCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        CGFloat(5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        CGFloat(5)
    }

}


// MARK: - UICollectionViewDataSource
extension ReviewManagementCollectionViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfMovies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewManagementCollectionViewCell.identifier, for: indexPath) as! ReviewManagementCollectionViewCell
        
        if let movieReviews = presenter.movieReview(forRow: indexPath.row),
           let cellWidth = collectionViewCellWidth {
            
            cell.configure(movieReview: movieReviews)
            cell.setupLayout(width: cellWidth)
        }
        
        return cell
    }
    
}

// MARK: - ReviewManagementPresenterOutput
extension ReviewManagementCollectionViewController : ReviewManagementPresenterOutput {
    
    func updataMovieReview() {
        collectionView.reloadData()
    }
    
}
