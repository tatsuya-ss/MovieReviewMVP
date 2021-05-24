//
//  ReviewManagementCollectionViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//



import UIKit

class ReviewManagementCollectionViewController: UIViewController {
    
    private var collectionView: UICollectionView!
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
        setupCollectionView()
        setupTabBar()
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
    
    
    @objc func trashButtonTapped() {
        presenter.didDeleteReviewMovie(indexs: collectionView.indexPathsForSelectedItems)
    }

    
    
    func setupCollectionView() {
        
        colunmFlowLayout = ColumnFlowLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: colunmFlowLayout)
        collectionView.autoresizingMask = [ .flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .black
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        [collectionView.topAnchor.constraint(equalTo: view.topAnchor),
         collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
         collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),].forEach { $0.isActive = true}
        
        collectionView.allowsMultipleSelection = true

        collectionView.register(ReviewManagementCollectionViewCell.nib, forCellWithReuseIdentifier: ReviewManagementCollectionViewCell.identifier)
    }

}

// MARK: - UICollectionViewDelegate
extension ReviewManagementCollectionViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ReviewManagementCollectionViewCell else { return }
        
        if isEditing == true {
            cell.tapCell(state: .selected)
        } else {
            presenter.didSelectRow(at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ReviewManagementCollectionViewCell else { return }
        
        if isEditing == true {
            cell.tapCell(state: .deselected)
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
    
    
    func updateItem(_ state: MovieUpdateState, _ index: Int?) {
        
        switch state {
        
        case .initial:
            collectionView.reloadData()

        case .delete:
            guard let index = index else { return }
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        case .insert:
            
            collectionView.reloadData()

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
            
            // trueになった時、一旦全選択解除
            if let indexPaths = indexPaths {
                for index in indexPaths {
                    collectionView.deselectItem(at: index, animated: false)
                }
            }
            
        case false:
            trashButton.isEnabled = false
            tabBarController?.tabBar.isHidden = false
            
            // falseになった時も、全選択解除して、cell選択時のエフェクトも解除
            if let indexPaths = indexPaths {
                for index in indexPaths {
                    collectionView.deselectItem(at: index, animated: false)
                    collectionView.reloadItems(at: [IndexPath(item: index.row, section: 0)])
                }
            }
        }
    }
    
    
    
    func displayMyReview(_ movie: MovieReviewElement) {
        
        let reviewMovieVC = UIStoryboard(name: "ReviewMovie", bundle: nil).instantiateInitialViewController() as! ReviewMovieViewController
        
        let model = ReviewMovieModel(movie: movie, movieReviewElement: movie)
        
        let presenter = ReviewMoviePresenter(movieReviewState: .afterStore, movieReviewElement: movie, view: reviewMovieVC, model: model)
                
        reviewMovieVC.inject(presenter: presenter)
        
        let nav = UINavigationController(rootViewController: reviewMovieVC)
        
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
    }

    
}
