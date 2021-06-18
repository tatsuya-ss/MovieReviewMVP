//
//  StockReviewMovieManagementPresenter.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/16.
//

import Foundation

protocol StockReviewMovieManagementPresenterInput {
    var numberOfStockMovies: Int { get }
    func returnStockMovieForCell(forRow row: Int) -> MovieReviewElement
    func fetchStockMovies()
    func returnSortState() -> sortState
    func didTapSortButton(_ sortState: sortState)
}

protocol StockReviewMovieManagementPresenterOutput : AnyObject {
    func sortReview()
}


final class StockReviewMovieManagementPresenter : StockReviewMovieManagementPresenterInput {
    
    private weak var view: StockReviewMovieManagementPresenterOutput!
    private var model: StockReviewMovieManagementModelInput
    private(set) var movieReviewStockElements: [MovieReviewElement] = []
    private var sortStateManagement: sortState = .createdDescend

    
    init(view: StockReviewMovieManagementPresenterOutput, model: StockReviewMovieManagementModelInput) {
        self.view = view
        self.model = model
    }
    
    func returnSortState() -> sortState {
        sortStateManagement
    }

    var numberOfStockMovies: Int {
        movieReviewStockElements.count
    }
    
    func returnStockMovieForCell(forRow row: Int) -> MovieReviewElement {
        movieReviewStockElements[row]
    }
    
    func fetchStockMovies() {
        movieReviewStockElements = model.fetchStockMovies(sortState: sortStateManagement)
    }
    
    func didTapSortButton(_ sortState: sortState) {
        sortStateManagement = sortState
        movieReviewStockElements = model.sortReview(sortState, isStoredAsReview: false)
        view.sortReview()
    }
    
}
