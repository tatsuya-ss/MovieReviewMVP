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
    @IBOutlet weak var trashButton: UIBarButtonItem!
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
        isEditing = false
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        presenter.changeEditingStateProcess(editing, collectionView.indexPathsForSelectedItems)
        
    }
    
    @IBAction func trashButtonTapped(_ sender: Any) {
        presenter.didDeleteReviewMovie(indexs: collectionView.indexPathsForSelectedItems)
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
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    func setupTabBar() {
        tabBarController?.tabBar.isTranslucent = false
    }
    
    
    func setupCollectionView() {
        collectionView.register(ReviewManagementCollectionViewCell.nib, forCellWithReuseIdentifier: ReviewManagementCollectionViewCell.identifier)
        collectionView.allowsMultipleSelection = true
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

// MARK: - UICollectionViewDelegate
extension ReviewManagementCollectionViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ReviewManagementCollectionViewCell else { return }
        if isEditing == true {
            cell.selectedCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ReviewManagementCollectionViewCell else { return }
        if isEditing == true {
            cell.deselectedCell()
        }
        
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
    
    
    func updateItem(_ state: movieUpdateState, _ index: Int?) {
        
        switch state {
        
        case .initial:
            collectionView.reloadData()

        case .delete:
            guard let index = index else { return }
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])

        case .insert:
            guard let index = index else { return }
            collectionView.insertItems(at: [IndexPath(item: index, section: 0)])

        case .modificate:
            guard let index = index else { return }
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])

        }
        
        isEditing = false
    }
    
    func deselectItem(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        
        switch editing {
        case true:
            trashButton.isEnabled = true
            collectionView.allowsMultipleSelection = true
            tabBarController?.tabBar.isHidden = true
            
            if let indexPaths = indexPaths {
                for index in indexPaths {
                    collectionView.deselectItem(at: index, animated: false)
                }
            }
            
        case false:
            trashButton.isEnabled = false
            tabBarController?.tabBar.isHidden = false
            
            if let indexPaths = indexPaths {
                for index in indexPaths {
                    collectionView.deselectItem(at: index, animated: false)
                    collectionView.reloadItems(at: [IndexPath(item: index.row, section: 0)])
                }
            }
        }
    }
    
}
