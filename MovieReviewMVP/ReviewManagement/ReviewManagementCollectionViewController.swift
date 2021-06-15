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
    private var stockCollectionView: UICollectionView!
    private var stockColunmFlowLayout: UICollectionViewFlowLayout!
    private var stockCollectionViewHeight: CGFloat?
    private var sortButton: UIBarButtonItem!
    private var editButton: UIBarButtonItem!
    private var trashButton: UIButton!
    
    let movieUseCase = MovieUseCase()
    
    private(set) var presenter: ReviewManagementPresenterInput!
    func inject(presenter: ReviewManagementPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
//        movieUseCase.notification(presenter)
        presenter.fetchUpdateReviewMovies(.initial)
        isEditing = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if appDelegate.isInsert {
            presenter.fetchUpdateReviewMovies(.insert)
            appDelegate.isInsert = false
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let indexPaths: [[IndexPath]?] = [collectionView.indexPathsForSelectedItems, stockCollectionView.indexPathsForSelectedItems]
        presenter.changeEditingStateProcess(editing, indexPaths)
        
    }
    
    @IBAction func saveButtonTappedSegue(segue: UIStoryboardSegue) {
        guard let reviewMovieViewController = segue.source as? ReviewMovieViewController else { return }
        let movieUpdateState = reviewMovieViewController.presenter.returnMovieUpdateState()
        presenter.fetchUpdateReviewMovies(movieUpdateState)
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
            trashButton.heightAnchor.constraint(equalTo: trashButton.widthAnchor)
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
         collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ].forEach { $0.isActive = true}
        collectionView.allowsMultipleSelection = true
        collectionView.register(ReviewManagementCollectionViewCell.nib, forCellWithReuseIdentifier: ReviewManagementCollectionViewCell.identifier)
        collectionView.register(ReviewMovieManagementCollectionReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ReviewMovieManagementCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        
        // stockCollectionView
        stockColunmFlowLayout = StockColumnFlowLayout()
        stockCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: stockColunmFlowLayout)
        stockCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stockCollectionView.backgroundColor = .black
        stockCollectionView.alwaysBounceHorizontal = true
        stockCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stockCollectionView)
        [stockCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
         stockCollectionView.heightAnchor.constraint(equalToConstant: view.bounds.height / 7),
         stockCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
         stockCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ].forEach { $0.isActive = true}
        stockCollectionView.allowsMultipleSelection = true
        stockCollectionView.register(StockReviewMovieCollectionViewCell.nib, forCellWithReuseIdentifier: StockReviewMovieCollectionViewCell.identifier)
        collectionView.contentInset.top = view.bounds.height / 7
        stockCollectionViewHeight = view.bounds.height / 7
        stockCollectionView.dataSource = self
        stockCollectionView.delegate = self
        

    }
    
    
    
}

// MARK: - @objc
extension ReviewManagementCollectionViewController {
    @objc func trashButtonTapped() {
        
        let deleteAlert = UIAlertController(title: nil, message: "選択したレビューを削除しますか？", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "レビューを削除", style: .destructive, handler: { _ in
            guard let reviewSortedIndex = (self.collectionView.indexPathsForSelectedItems?.sorted { $0 > $1 }),
                  let stockSortedIndex = (self.stockCollectionView.indexPathsForSelectedItems?.sorted { $0 > $1 }) else { return }
            self.presenter.didDeleteReviewMovie(.delete, indexs: reviewSortedIndex)
            self.presenter.didDeleteStockMovie(.delete, indexs: stockSortedIndex)
        }))
        deleteAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        self.present(deleteAlert, animated: true, completion: nil)
    }

}

// MARK: - UICollectionViewDelegate
extension ReviewManagementCollectionViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.collectionView:
            guard let cell = collectionView.cellForItem(at: indexPath) as? ReviewManagementCollectionViewCell else { return }
            if isEditing == true {
                cell.tapCell(state: .selected)
                collectionView.indexPathsForSelectedItems == [] ? (trashButton.isEnabled = false) : (trashButton.isEnabled = true)
            } else {
                presenter.didSelectRowCollectionView(at: indexPath)
                collectionView.deselectItem(at: indexPath, animated: false)
            }

        case stockCollectionView:
            guard let cell = collectionView.cellForItem(at: indexPath) as? StockReviewMovieCollectionViewCell else { return }
            if isEditing == true {
                cell.tapCell(state: .selected)
                collectionView.indexPathsForSelectedItems == [] ? (trashButton.isEnabled = false) : (trashButton.isEnabled = true)
            } else {
                presenter.didSelectRowStockCollectionView(at: indexPath)
                collectionView.deselectItem(at: indexPath, animated: false)
            }

            print("tap\(indexPath.row)")
        default:
            break
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing == true {
            switch collectionView {
            case self.collectionView:
                guard let cell = collectionView.cellForItem(at: indexPath) as? ReviewManagementCollectionViewCell else { return }
                    cell.tapCell(state: .deselected)
                    collectionView.indexPathsForSelectedItems == [] ? (trashButton.isEnabled = false) : (trashButton.isEnabled = true)
            case stockCollectionView:
                guard let cell = collectionView.cellForItem(at: indexPath) as? StockReviewMovieCollectionViewCell else { return }
                    cell.tapCell(state: .deselected)
                    collectionView.indexPathsForSelectedItems == [] ? (trashButton.isEnabled = false) : (trashButton.isEnabled = true)
            default:
                break
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            guard let stockCollectionViewHeight = stockCollectionViewHeight else { return }
            let contentOffset = scrollView.contentOffset.y
            
            if contentOffset <= -stockCollectionViewHeight {
                stockCollectionView.isHidden = false
                collectionView.contentInset.top = stockCollectionViewHeight
                stockCollectionView.frame.origin.y = 0
            } else if contentOffset <= 0 {
                stockCollectionView.isHidden = false
                collectionView.contentInset.top = stockCollectionViewHeight - (contentOffset + stockCollectionViewHeight)
                stockCollectionView.frame.origin.y = -(stockCollectionViewHeight + contentOffset)
            } else {
                stockCollectionView.isHidden = true
                stockCollectionView.frame.origin.y = -(stockCollectionViewHeight)
            }
        }
        
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension ReviewManagementCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case self.collectionView:
            return CGFloat(10)
        case stockCollectionView:
            return CGFloat(5)
        default:
            return CGFloat(10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case self.collectionView:
            return CGFloat(1)
        case stockCollectionView:
            return CGFloat(1)
        default:
            return CGFloat(1)
        }

    }
    
}


// MARK: - UICollectionViewDataSource
extension ReviewManagementCollectionViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.collectionView:
            print(presenter.numberOfMovies)
            return presenter.numberOfMovies

        case stockCollectionView:
            print(presenter.numberOfStockMovies)
            return presenter.numberOfStockMovies
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case self.collectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewManagementCollectionViewCell.identifier, for: indexPath) as! ReviewManagementCollectionViewCell
            if let movieReviews = presenter.returnMovieReviewForCell(forRow: indexPath.row) {
                cell.configure(movieReview: movieReviews)
                if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
                    cell.tapCell(state: .selected)
                } else {
                    cell.tapCell(state: .deselected)
                }
            }
            
            return cell

            
        default:
            let cell = stockCollectionView.dequeueReusableCell(withReuseIdentifier: StockReviewMovieCollectionViewCell.identifier, for: indexPath) as! StockReviewMovieCollectionViewCell
            if let movieReviews = presenter.returnStockMovieReviewForCell(forRow: indexPath.row) {
                cell.configure(movieReview: movieReviews)
            }
            if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
                cell.tapCell(state: .selected)
            } else {
                cell.tapCell(state: .deselected)
            }
        
        return cell

        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch collectionView {
        case self.collectionView:
            if kind == UICollectionView.elementKindSectionHeader,
               let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ReviewMovieManagementCollectionReusableView.identifier, for: indexPath) as? ReviewMovieManagementCollectionReusableView {
                headerView.titleLabel.text = "レビュー"
                return headerView
            }

        default:
            return UICollectionReusableView()
        }
        
        return UICollectionReusableView()
    }
    
}

// MARK: - ReviewManagementPresenterOutput
extension ReviewManagementCollectionViewController : ReviewManagementPresenterOutput {
    
    
    func sortReview() {
        if presenter.numberOfMovies == 0 || presenter.numberOfMovies == 1 {
            collectionView.reloadData()
        } else {
            for index in 0...presenter.numberOfMovies - 1 {
                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
        
        if presenter.numberOfStockMovies == 0 || presenter.numberOfStockMovies == 1 {
            stockCollectionView.reloadData()
        } else {
            for index in 0...presenter.numberOfStockMovies - 1 {
                stockCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }

    }
    
    
    // MARK: 初期化、削除、挿入、修正を行う
    func updateReview(_ movieUpdateState: MovieUpdateState, _ index: Int?, _ collectionViewState: collectionViewState?) {
        
        switch movieUpdateState {
        
        case .initial:
            collectionView.reloadData()
            stockCollectionView.reloadData()
            
        case .delete:
            guard let index = index,
                  let collectionViewState = collectionViewState else { return }
            switch collectionViewState {
            case .review:
                collectionView.performBatchUpdates {
                    collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            case .stock:
                stockCollectionView.performBatchUpdates {
                    stockCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }
            
            
        case .insert:
            
            if presenter.numberOfMovies == 0 || presenter.numberOfMovies == 1 {
                collectionView.reloadData()
            } else {
                for index in 0...presenter.numberOfMovies - 1 {
                    
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
            
            if presenter.numberOfStockMovies == 0 || presenter.numberOfStockMovies == 1 {
                stockCollectionView.reloadData()
            } else {
                for index in 0...presenter.numberOfStockMovies - 1 {
                    stockCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }

        case .modificate:
            if presenter.numberOfMovies == 0 || presenter.numberOfMovies == 1 {
                collectionView.reloadData()
            } else {
                for index in 0...presenter.numberOfMovies - 1 {
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
            
            if presenter.numberOfStockMovies == 0 || presenter.numberOfStockMovies == 1 {
                stockCollectionView.reloadData()
            } else {
                for index in 0...presenter.numberOfStockMovies - 1 {
                    stockCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }

        }
        
        isEditing = false
    }
    
    // MARK: 選択解除を行う
    func changeTheDisplayDependingOnTheEditingState(_ editing: Bool, _ indexPaths: [[IndexPath]?]) {
        
        switch editing {
        case true:
            tabBarController?.tabBar.isHidden = true
            sortButton.isEnabled = false
            trashButton.isHidden = false
            trashButton.isEnabled = false
            // trueになった時、一旦全選択解除
            if let indexPaths = indexPaths[0] {
                for index in indexPaths {
                    collectionView.deselectItem(at: index, animated: true)
                }
            }
            if let indexPaths = indexPaths[1] {
                for index in indexPaths {
                    stockCollectionView.deselectItem(at: index, animated: true)
                }
            }
            
        case false:
            tabBarController?.tabBar.isHidden = false
            sortButton.isEnabled = true
            trashButton.isHidden = true
            // falseになった時も、全選択解除して、cell選択時のエフェクトも解除
            if let indexPaths = indexPaths[0] {
                for index in indexPaths {
                    collectionView.deselectItem(at: index, animated: true)
                    collectionView.reloadItems(at: [IndexPath(item: index.row, section: 0)])
                }
            }
            if let indexPaths = indexPaths[1] {
                for index in indexPaths {
                    stockCollectionView.deselectItem(at: index, animated: true)
                    stockCollectionView.reloadItems(at: [IndexPath(item: index.row, section: 0)])
                }
            }
        }
    }
    
    
    // MARK: tapしたレビューを詳細表示
    func displaySelectMyReview(_ movie: MovieReviewElement, afterStoreState: afterStoreState, movieUpdateState: MovieUpdateState) {
        
        let reviewMovieVC = UIStoryboard(name: "ReviewMovie", bundle: nil).instantiateInitialViewController() as! ReviewMovieViewController
        
        let model = ReviewMovieModel(movie: movie, movieReviewElement: movie)
        
        let presenter = ReviewMoviePresenter(movieReviewState: .afterStore(afterStoreState), movieReviewElement: movie, movieUpdateState: movieUpdateState, view: reviewMovieVC, model: model)
                
        reviewMovieVC.inject(presenter: presenter)
        
        let nav = UINavigationController(rootViewController: reviewMovieVC)
        
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
    }

    
}
