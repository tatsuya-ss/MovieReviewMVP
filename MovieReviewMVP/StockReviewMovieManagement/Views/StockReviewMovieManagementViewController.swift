//
//  StockReviewMovieManagementViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/16.
//

import UIKit

extension StockReviewMovieManagementViewController: UIActivityIndicatorProtocol { }

final class StockReviewMovieManagementViewController: UIViewController {
    
    @IBOutlet private weak var stockCollectionView: UICollectionView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
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
        setupIndicator()
        presenter.fetchStockMovies()
        setupTrashButton()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let indexPaths = stockCollectionView.indexPathsForSelectedItems
        presenter.changeEditingStateProcess(editing, indexPaths)
    }
    
    private func setupIndicator() {
        setupIndicator(indicator: activityIndicatorView)
        startIndicator(indicator: activityIndicatorView)
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
        navigationItem.title = .stock
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),
                                                                   NSAttributedString.Key.foregroundColor: UIColor.stringColor]

        // MARK: navigationBarを透明にする
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        // MARK: キャンセルボタン
        stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
        navigationItem.leftBarButtonItem = stopButton
        // MARK: 編集ボタン
        editButton = editButtonItem
        editButton.title = .selectTitle
        // MARK: 並び替えボタン
        if #available(iOS 14.0, *) {
            let sortMenu = UIMenu.makeSortMenuForStock(presenter: presenter)
            sortButton = UIBarButtonItem(title: presenter.returnSortState().buttonTitle, image: nil, primaryAction: nil, menu: sortMenu)
        } else {
            sortButton = UIBarButtonItem(title: presenter.returnSortState().buttonTitle,
                                         style: .done,
                                         target: self,
                                         action: #selector(sortButtonTapped))
        }
        
        [stopButton, editButton, sortButton].forEach { $0.tintColor = .stringColor }
        navigationItem.rightBarButtonItems = [editButton, sortButton]

    }
    
    @objc func stopButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupTrashButton() {
        
        trashButton = UIButton()
        trashButton.setImage(UIImage(named: .trashImage), for: .normal)
        trashButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        trashButton.tintColor = .black
        trashButton.backgroundColor = .baseColor
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
        stockCollectionView.addSubview(trashButton)
        
        let buttonWidth: CGFloat = 55
        
        [trashButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
         trashButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
         trashButton.widthAnchor.constraint(equalToConstant: buttonWidth),
         trashButton.heightAnchor.constraint(equalTo: trashButton.widthAnchor)
        ].forEach { $0.isActive = true }
        
        trashButton.layer.cornerRadius = buttonWidth / 2
        
//        trashButton.layer.shadowColor = UIColor.black.cgColor
//        trashButton.layer.shadowOffset = CGSize(width: 0, height: 3)
//        trashButton.layer.shadowOpacity = 0.7
//        trashButton.layer.shadowRadius = 10
//        
//        trashButton.layer.shouldRasterize = true
//        trashButton.layer.rasterizationScale = UIScreen.main.scale
        
        trashButton.isHidden = true
    }
    
    @objc func trashButtonTapped(_ sender: UIBarButtonItem) {
        let deleteAlert = UIAlertController(title: nil, message: .deleteAlertMessage, preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title: .deleteAlertTitle, style: .destructive, handler: { _ in
            guard let reviewSortedIndexs = (self.stockCollectionView.indexPathsForSelectedItems?.sorted { $0 > $1 }) else { return }
            self.presenter.didDeleteReviewMovie(.delete, indexPaths: reviewSortedIndexs)
        }))
        deleteAlert.addAction(UIAlertAction(title: .cancelAlert, style: .cancel, handler: nil))
        self.present(deleteAlert, animated: true, completion: nil)

    }

    @objc private func sortButtonTapped() {
        presenter.didTapSortButtoniOS13()
    }

}

// MARK: - UICollectionViewDataSource
extension StockReviewMovieManagementViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfStockMovies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = stockCollectionView.dequeueReusableCell(withReuseIdentifier: StockReviewMovieCollectionViewCell.identifier, for: indexPath) as! StockReviewMovieCollectionViewCell
        let stock = presenter.returnStockMovieForCell(forRow: indexPath.row)
        let posterImage = (stock.posterData == nil) ? UIImage(named: "no_image") : UIImage(data: stock.posterData!)
        let cellSelectState: CellSelectedState = (collectionView.indexPathsForSelectedItems?.contains(indexPath) == true) ? .selected : .deselected
        cell.configure(posterImage: posterImage, cellSelectState: cellSelectState)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension StockReviewMovieManagementViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        CGFloat(5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // 垂直スクロールの横幅
        CGFloat(5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? StockReviewMovieCollectionViewCell else { return }
        if isEditing {
            cell.tapCell(state: .selected)
            stockCollectionView.indexPathsForSelectedItems == [] ? (trashButton.isEnabled = false) : (trashButton.isEnabled = true)
        } else {
            presenter.didSelectRowStockCollectionView(at: indexPath)
            stockCollectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing {
            guard let cell = collectionView.cellForItem(at: indexPath) as? StockReviewMovieCollectionViewCell else { return }
            cell.tapCell(state: .deselected)
            stockCollectionView.indexPathsForSelectedItems == [] ? (trashButton.isEnabled = false) : (trashButton.isEnabled = true)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension StockReviewMovieManagementViewController : UICollectionViewDelegate {
    
}

// MARK: - StockReviewMovieManagementPresenterOutput
extension StockReviewMovieManagementViewController : StockReviewMovieManagementPresenterOutput {
    
    func sortReview() {
        if presenter.numberOfStockMovies > 1 {
            for index in 0...presenter.numberOfStockMovies - 1 {
                stockCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
        sortButton.title = presenter.returnSortState().buttonTitle
        print("\(presenter.returnSortState().buttonTitle)に並び替えました。stock")
        
    }
    
    func changeTheDisplayDependingOnTheEditingState(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        switch editing {
        case true:
            sortButton.isEnabled = false
            trashButton.isHidden = false
            editButton.title = .deselectTitle
            guard let indexPaths = indexPaths else { return }
            for index in indexPaths {
                stockCollectionView.deselectItem(at: index, animated: true)
            }
            
        case false:
            sortButton.isEnabled = true
            trashButton.isHidden = true
            editButton.title = .selectTitle
            guard let indexPaths = indexPaths else { return }
            for index in indexPaths {
                stockCollectionView.deselectItem(at: index, animated: true)
                stockCollectionView.reloadItems(at: [IndexPath(item: index.row, section: 0)])
            }
        }
    }
    
    func updateStockCollectionView(movieUpdateState: MovieUpdateState, indexPath: IndexPath?) {
        defer { stopIndicator(indicator: activityIndicatorView) }
        switch movieUpdateState {
        case .initial:
            stockCollectionView.reloadData()
        case .delete:
            guard let indexPath = indexPath else { return }
            stockCollectionView.performBatchUpdates {
                stockCollectionView.deleteItems(at: [IndexPath(item: indexPath.row, section: 0)])
            }
        case .insert:
            break
        case .modificate:
            break
        }
        
        isEditing = false
    }
    
    func displayReviewMovieView(_ movie: VideoWork, afterStoreState: afterStoreState, movieUpdateState: MovieUpdateState) {
//        let reviewMovieVC = UIStoryboard(name: .reviewMovieStoryboardName, bundle: nil).instantiateInitialViewController() as! ReviewMovieViewController
        let reviewMovieVC = SelectStockReviewViewController()
        let videoWorkUseCase = VideoWorkUseCase(repository: VideoWorksRepository(dataStore: TMDbDataStore()))
        let reviewUseCase = ReviewUseCase(repository: ReviewRepository(dataStore: ReviewDataStore()))
        let userUseCase = UserUseCase(repository: UserRepository(dataStore: UserDataStore()))

        let presenter = SelectStockReviewPresenter(view: reviewMovieVC, selectedReview: SelectedReview(review: movie), reviewUseCase: reviewUseCase, userUseCase: userUseCase, videoWorkuseCase: videoWorkUseCase)
        reviewMovieVC.inject(presenter: presenter)
        navigationController?.pushViewController(reviewMovieVC, animated: true)
    }

    func displaySortAction() {
        let sortAlert = UIAlertController.makeSortAlertForStockReview(presenter: presenter)
        if UIDevice.current.userInterfaceIdiom == .pad {
            sortAlert.popoverPresentationController?.sourceView = self.view
            sortAlert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.maxX - 100, y: view.safeAreaInsets.top, width: 0, height: 0)
        }
        present(sortAlert, animated: true, completion: nil)

    }
}
