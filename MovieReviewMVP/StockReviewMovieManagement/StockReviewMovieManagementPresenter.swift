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
}

protocol StockReviewMovieManagementPresenterOutput : AnyObject {
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
    
    var numberOfStockMovies: Int {
        movieReviewStockElements.count
    }
    
    func returnStockMovieForCell(forRow row: Int) -> MovieReviewElement {
        movieReviewStockElements[row]
    }
    
    func fetchStockMovies() {
        movieReviewStockElements = model.fetchStockMovies(sortState: sortStateManagement)
    }
    
}
