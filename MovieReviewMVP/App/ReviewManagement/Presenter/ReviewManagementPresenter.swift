//
//  ReviewManagementPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/09.
//

import Foundation

protocol ReviewManagementPresenterInput {
    var numberOfMovies: Int { get }
    func returnMovieReviewForCell(forRow row: Int) -> VideoWork
    func returnSortState() -> sortState
    func returnMovieReview() -> [VideoWork]
    func didDeleteReviewMovie(_ movieUpdateState: MovieUpdateState, indexPaths: [IndexPath])
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState)
    func didTapSortButtoniOS13()
    func didLogout()
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func fetchUpdateReviewMovies()
    func didTapItemAt(isEditing: Bool, indexPath: IndexPath, cellSelectedState: CellSelectedState)
}

protocol ReviewManagementPresenterOutput: AnyObject {
    func changeTheDisplayDependingOnTheEditingState(_ editing: Bool, _ indexPaths: [IndexPath]?)
    func updateReview()
    func deleteReview(indexPath: IndexPath)
    func displaySelectMyReview(selectReview: VideoWork, afterStoreState: afterStoreState, movieUpdateState: MovieUpdateState)
    func sortReview()
    func displaySortAction()
    func changeTapCellState(indexPath: IndexPath, cellSelectedState: CellSelectedState)
    func changeSortButtonTitle(sortState: sortState)
}


final class ReviewManagementPresenter : ReviewManagementPresenterInput {
    
    private weak var view: ReviewManagementPresenterOutput!
    private let reviewUseCase: ReviewUseCaseProtocol
    private var videoWorkuseCase: VideoWorkUseCaseProtocol
    private var movieUpdateState: MovieUpdateState = .modificate
    private let reviewManagement = ReviewManagement()
    
    init(view: ReviewManagementPresenterOutput,
         reviewUseCase: ReviewUseCaseProtocol,
         videoWorkuseCase: VideoWorkUseCaseProtocol) {
        self.view = view
        self.reviewUseCase = reviewUseCase
        self.videoWorkuseCase = videoWorkuseCase
    }
    
    var numberOfMovies: Int {
        let reviewCount = reviewManagement.returnNumberOfReviews()
        return reviewCount
    }
    
    func returnSortState() -> sortState {
        reviewManagement.returnSortState()
    }
    
    func returnMovieReview() -> [VideoWork] {
        reviewManagement.returnReviews()
    }
    
    func returnMovieReviewForCell(forRow row: Int) -> VideoWork {
        reviewManagement.returnReviewForCell(forRow: row)
    }
    
    func changeEditingStateProcess(_ editing: Bool, _ indexPaths: [IndexPath]?) {
        view.changeTheDisplayDependingOnTheEditingState(editing, indexPaths)
    }
    
    func didTapItemAt(isEditing: Bool, indexPath: IndexPath, cellSelectedState: CellSelectedState) {
        if isEditing {
            view.changeTapCellState(indexPath: indexPath, cellSelectedState: cellSelectedState)
        } else {
            let selectReview = reviewManagement.returnSelectedReview(indexPath: indexPath)
            view.displaySelectMyReview(selectReview: selectReview, afterStoreState: .reviewed, movieUpdateState: movieUpdateState)
        }
    }
    
    func fetchUpdateReviewMovies() {
        let sortState = reviewManagement.returnSortState()
        let dispatchGroup = DispatchGroup()
        
        self.reviewUseCase.sort(isStoredAsReview: true, sortState: sortState) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                self?.reviewManagement.fetchReviews(state: .search(.initial), results: result)
                result.enumerated().forEach { videoWorks in
                    dispatchGroup.enter()
                    self?.videoWorkuseCase.fetchPosterImage(posterPath: videoWorks.element.posterPath) { result in
                        defer { dispatchGroup.leave() }
                        switch result {
                        case .failure(let error):
                            print(error)
                        case.success(let data):
                            self?.reviewManagement.fetchPosterData(index: videoWorks.offset, data: data)
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self?.view.updateReview()
                }
            }
        }
        
    }
    
    func didDeleteReviewMovie(_ movieUpdateState: MovieUpdateState, indexPaths: [IndexPath]) {
        indexPaths
            .sorted { $0 > $1 }
            .forEach {
                print($0)
                let selectedReview = reviewManagement.returnSelectedReview(indexPath: $0)
                reviewUseCase.delete(movie: selectedReview)
                reviewManagement.deleteReview(row: $0.row)
                view.deleteReview(indexPath: $0)
            }
    }
    
    
    func didTapSortButton(isStoredAsReview: Bool, sortState: sortState) {
        view.changeSortButtonTitle(sortState: sortState)
        let isSorted = reviewManagement.returnNumberOfReviews() > 1
        if isSorted {
            reviewManagement.sortReviews(sortState: sortState)
            view.sortReview()
        }
    }
    
    func didTapSortButtoniOS13() {
        view.displaySortAction()
    }
    
    func didLogout() {
        reviewManagement.logout()
        view.updateReview()
    }
    
}
