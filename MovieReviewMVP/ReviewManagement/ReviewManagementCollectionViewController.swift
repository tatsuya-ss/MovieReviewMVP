//
//  ReviewManagementCollectionViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//



import UIKit

class ReviewManagementCollectionViewController: UIViewController {
    
    private var collectionview: UICollectionView!
    private var colunmFlowLayout: UICollectionViewFlowLayout!

    @IBOutlet weak var trashButton: UIBarButtonItem!
    let movieUseCase = MovieUseCase()
    
    private var presenter: ReviewManagementPresenterInput!
    func inject(presenter: ReviewManagementPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        collectionview.dataSource = self
        collectionview.delegate = self
        movieUseCase.notification(presenter)
        isEditing = false
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        presenter.changeEditingStateProcess(editing, collectionview.indexPathsForSelectedItems)
        
    }
    
    @IBAction func trashButtonTapped(_ sender: Any) {
        presenter.didDeleteReviewMovie(indexs: collectionview.indexPathsForSelectedItems)
    }
    
    
}

// MARK: - setup
private extension ReviewManagementCollectionViewController {
    
    func setup() {
        setupPresenter()
        setupNavigation()
        setupTabBar()
        setupCollectionView()
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
        
        colunmFlowLayout = ColumnFlowLayout()
        
        collectionview = UICollectionView(frame: view.bounds, collectionViewLayout: colunmFlowLayout)
        collectionview.autoresizingMask = [ .flexibleWidth, .flexibleHeight]
        collectionview.backgroundColor = .black
        collectionview.alwaysBounceVertical = true
        view.addSubview(collectionview)
        
        
        collectionview.allowsMultipleSelection = true

        collectionview.register(ReviewManagementCollectionViewCell.nib, forCellWithReuseIdentifier: ReviewManagementCollectionViewCell.identifier)
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
        CGFloat(10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        CGFloat(1)
    }
    
}


// MARK: - UICollectionViewDataSource
extension ReviewManagementCollectionViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfMovies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewManagementCollectionViewCell.identifier, for: indexPath) as! ReviewManagementCollectionViewCell
        
        if let movieReviews = presenter.movieReview(forRow: indexPath.row) {
            cell.configure(movieReview: movieReviews)
            cell.setupLayout()
        }
        
        return cell
    }
    
}

// MARK: - ReviewManagementPresenterOutput
extension ReviewManagementCollectionViewController : ReviewManagementPresenterOutput {
    
    
    func updateItem(_ state: movieUpdateState, _ index: Int?) {
        
        switch state {
        
        case .initial:
            collectionview.reloadData()

        case .delete:
            guard let index = index else { return }
            collectionview.deleteItems(at: [IndexPath(item: index, section: 0)])

        case .insert:
            guard let index = index else { return }
            collectionview.insertItems(at: [IndexPath(item: index, section: 0)])

        case .modificate:
            guard let index = index else { return }
            collectionview.reloadItems(at: [IndexPath(item: index, section: 0)])

        }
        
        isEditing = false
    }
    
    func deselectItem(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        
        switch editing {
        case true:
            trashButton.isEnabled = true
            collectionview.allowsMultipleSelection = true
            tabBarController?.tabBar.isHidden = true
            
            if let indexPaths = indexPaths {
                for index in indexPaths {
                    collectionview.deselectItem(at: index, animated: false)
                }
            }
            
        case false:
            trashButton.isEnabled = false
            tabBarController?.tabBar.isHidden = false
            
            if let indexPaths = indexPaths {
                for index in indexPaths {
                    collectionview.deselectItem(at: index, animated: false)
                    collectionview.reloadItems(at: [IndexPath(item: index.row, section: 0)])
                }
            }
        }
    }
    
}
