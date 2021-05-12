//
//  MovieDataStore.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//

import RealmSwift

struct MovieReviewSave : MovieReviewRepository {
    
    func setMovieReview(_ movie: MovieReviewElement) {
        let myMovie = RealmMyMovieInfomations()
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
    
    func fetchMovieReview() -> [MovieReviewElement] {
        var movieReviews: [RealmMyMovieInfomations] = []
        let realm = try! Realm()
         let movies = realm.objects(RealmMyMovieInfomations.self)
        for movie in movies {
            movieReviews.append(movie)
        }
        var movieReviewContents: [MovieReviewElement] = []
        for movie in movieReviews {
            movieReviewContents.append(MovieReviewElement(title: movie.title, reviewStars: movie.reviewStars, releaseDay: movie.releaseDay, overview: movie.overview, review: movie.review, movieImagePath: movie.movieImagePath))
        }
        return movieReviewContents
    }
    
    func saveMovieReview(_ movie: MovieReviewElement) {
        let myMovie = RealmMyMovieInfomations()
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
    
    func deleteMovieReview(_ index: IndexPath) {
        let realm = try! Realm()
        let movies = realm.objects(RealmMyMovieInfomations.self)
        
        try! realm.write {
            realm.delete(movies[index.row])
        }
    }
    
}
