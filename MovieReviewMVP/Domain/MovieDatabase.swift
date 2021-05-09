//
//  MovieDatabase.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/08.
//

import Foundation
import RealmSwift

class MyMovieInfomations: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var reviewStars: Double = 0.0
    @objc dynamic var releaseDay: String = ""
    @objc dynamic var overview: String = ""
    @objc dynamic var review: String = ""
    @objc dynamic var movieImagePath: String = ""
}

struct MovieReviewContent {
    let title: String
    let reviewStars: Double
    let releaseDay: String
    let overview: String
    let review: String
    let movieImagePath: String
}

protocol MovieReviewRepository {
    func setMovieReview(_ movie: MovieReviewContent)
    func fetchMovieReview(_ index: IndexPath) -> MyMovieInfomations
    func saveMovieReview(_ movie: MovieReviewContent)
}

struct MovieReviewSave : MovieReviewRepository {
    func setMovieReview(_ movie: MovieReviewContent) {
        let myMovie = MyMovieInfomations()
        let realm = try! Realm()
        
        myMovie.title = movie.title
        myMovie.reviewStars = movie.reviewStars
        myMovie.releaseDay = movie.releaseDay
        myMovie.overview = movie.overview
        myMovie.review = movie.review
        myMovie.movieImagePath = movie.movieImagePath
        
        try! realm.write {
            realm.add(myMovie.self)
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func fetchMovieReview(_ index: IndexPath) -> MyMovieInfomations {
        let realm = try! Realm()
         let movie = realm.objects(MyMovieInfomations.self)[index.row]
        return movie
    }
    
    func saveMovieReview(_ movie: MovieReviewContent) {
        let myMovie = MyMovieInfomations()
        let realm = try! Realm()
        
        try! realm.write {
            myMovie.title = movie.title
            myMovie.reviewStars = movie.reviewStars
            myMovie.releaseDay = movie.releaseDay
            myMovie.overview = movie.overview
            myMovie.review = movie.review
            myMovie.movieImagePath = movie.movieImagePath
        }

    }
}
