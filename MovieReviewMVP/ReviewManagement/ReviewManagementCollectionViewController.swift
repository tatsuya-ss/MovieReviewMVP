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
    
    var sortButton: UIBarButtonItem!
    var editButton: UIBarButtonItem!
    var trashButton: UIButton!
    
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
    
}

// MARK: - setup
private extension ReviewManagementCollectionViewController {
    
    func setup() {
        setupPresenter()
        setupNavigation()
        setupCollectionView()
        setupTabBar()
        setupTrashButton()
    }
    
    func setupTrashButton() {
        
        trashButton = UIButton()
        trashButton.setImage(UIImage(systemName: "trash"), for: .normal)

        trashButton.tintColor = .white
        trashButton.backgroundColor = .systemBlue
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
        collectionView.addSubview(trashButton)
        
        let buttonWidth: CGFloat = 55
        
        [
            trashButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            trashButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            trashButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            trashButton.heightAnchor.constraint(equalTo: trashButton.widthAnchor),
        ].forEach { $0.isActive = true }
        
        trashButton.layer.cornerRadius = buttonWidth / 2
        
        trashButton.layer.shadowColor = UIColor.black.cgColor
        trashButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        trashButton.layer.shadowOpacity = 0.7
        trashButton.layer.shadowRadius = 10
        
        trashButton.isHidden = true
    }
    
    func setupPresenter() {
        let reviewManagementModel = ReviewManagementModel()
        let reviewManagementPresenter = ReviewManagementPresenter(view: self, model: reviewManagementModel)
        inject(presenter: reviewManagementPresenter)
    }

    func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: setNavigationTitleLeft(title: "レビュー"))
        
        sortButton = UIBarButtonItem(title: presenter.returnSortState().buttonTitle, image: nil, primaryAction: nil, menu: contextMenuActions())
        
        
        editButton = editButtonItem
        
        navigationItem.rightBarButtonItems = [editButton, sortButton]
        
    }

    
    func setNavigationTitleLeft(title: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 26)

        return label
    }
    
    // MARK: メニュー表示用にUIMenuを返すメソッド
    func contextMenuActions() -> UIMenu {
        
        let createdDescendAction = UIAction(title: sortState.createdDescend.title, image: nil, state: .off, handler: { _ in
            self.presenter.didTapsortButton(.createdDescend)
            self.sortButton.title = self.presenter.returnSortState().buttonTitle
            print("\(sortState.createdDescend.title)に並び替えました。")
        })

        let createdAscendAction = UIAction(title: sortState.createdAscend.title, image: nil, state: .off, handler: { _ in
            self.presenter.didTapsortButton(.createdAscend)
            self.sortButton.title = self.presenter.returnSortState().buttonTitle
            print("\(sortState.createdAscend.title)に並び替えました。")
        })
        
        let reviewStarAscendAction = UIAction(title: sortState.reviewStarAscend.title, image: nil, state: .off, handler: { _ in
            self.presenter.didTapsortButton(.reviewStarAscend)
            self.sortButton.title = self.presenter.returnSortState().buttonTitle
            print("\(sortState.reviewStarAscend.title)に並び替えました。")
        })
        
        let reviewStarDescendAction = UIAction(title: sortState.reviewStarDescend.title, image: nil, state: .off, handler: { _ in
            self.presenter.didTapsortButton(.reviewStarDescend)
            self.sortButton.title = self.presenter.returnSortState().buttonTitle
            print("\(sortState.reviewStarDescend.title)に並び替えました。")
        })
        
        let menu = UIMenu(children: [createdDescendAction, createdAscendAction, reviewStarAscendAction, reviewStarDescendAction])
        
        return menu

    }
    
    func setupTabBar() {
        tabBarController?.tabBar.isTranslucent = false
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

// MARK: - @objc
extension ReviewManagementCollectionViewController {
    @objc func trashButtonTapped() {
        
        let deleteAlert = UIAlertController(title: nil, message: "選択したレビューを削除しますか？", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "レビューを削除", style: .destructive, handler: { _ in
            let indexPathsForSelectedItems = self.collectionView.indexPathsForSelectedItems
            let sortedIndexPathsForSelectedItems = indexPathsForSelectedItems?.sorted { $0 > $1 }
            guard let sortedIndex = sortedIndexPathsForSelectedItems else { return }
            print(sortedIndex)
            
            self.presenter.didDeleteReviewMovie(.delete, indexs: sortedIndex)
            
        }))
        deleteAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        self.present(deleteAlert, animated: true, completion: nil)
        
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
    
    func sortReview() {
        
        for index in 0...presenter.numberOfMovies - 1 {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
        
    }
    
    
    // MARK: 初期化、削除、挿入、修正を行う
    func updateReview(_ state: MovieUpdateState, _ index: Int?) {
        
        switch state {
        
        case .initial:
            collectionView.reloadData()
            
        case .delete:
            guard let index = index else { return }
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            }
            
        case .insert:
            for index in 0...presenter.numberOfMovies - 1 {
                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }

        case .modificate:
            for index in 0...presenter.numberOfMovies - 1 {
                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }

        }
        
        isEditing = false
    }
    
    // MARK: 選択解除を行う
    func deselectReview(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        
        switch editing {
        case true:
            collectionView.allowsMultipleSelection = true
            tabBarController?.tabBar.isHidden = true
            sortButton.isEnabled = false
            trashButton.isHidden = false
            
            // trueになった時、一旦全選択解除
            if let indexPaths = indexPaths {
                for index in indexPaths {
                    collectionView.deselectItem(at: index, animated: false)
                }
            }
            
        case false:
            tabBarController?.tabBar.isHidden = false
            sortButton.isEnabled = true
            trashButton.isHidden = true
            // falseになった時も、全選択解除して、cell選択時のエフェクトも解除
            if let indexPaths = indexPaths {
                for index in indexPaths {
                    collectionView.deselectItem(at: index, animated: false)
                    collectionView.reloadItems(at: [IndexPath(item: index.row, section: 0)])
                }
            }
        }
    }
    
    
    // MARK: tapしたレビューを詳細表示
    func displaySelectMyReview(_ movie: MovieReviewElement) {
        
        let reviewMovieVC = UIStoryboard(name: "ReviewMovie", bundle: nil).instantiateInitialViewController() as! ReviewMovieViewController
        
        let model = ReviewMovieModel(movie: movie, movieReviewElement: movie)
        
        let presenter = ReviewMoviePresenter(movieReviewState: .afterStore, movieReviewElement: movie, view: reviewMovieVC, model: model)
                
        reviewMovieVC.inject(presenter: presenter)
        
        let nav = UINavigationController(rootViewController: reviewMovieVC)
        
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
    }

    
}
