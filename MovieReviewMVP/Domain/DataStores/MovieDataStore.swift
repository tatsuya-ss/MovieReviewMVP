//
//  MovieDataStore.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//

import RealmSwift

struct MovieDataStore : MovieReviewRepository {
    var notificationToken: NotificationToken?
    
    // MARK: 更新通知を受け取り、collectionViewをreload
    mutating func notification(_ presenter: ReviewManagementPresenterInput) {
        let realm = try! Realm()
        let results = realm.objects(RealmMyMovieInfomation.self)

        notificationToken = results.observe { changes in
            switch changes {
            case .initial:
                presenter.returnReviewContent()
                print("初期表示を行いました")
            case let .update(_, deletions, insertions, modifications):
                presenter.returnReviewContent()
                print("更新処理を行いました",deletions, insertions, modifications)
            case let .error(error):
                print(error)
            }
        }
    }
    
    
    func createMovieReview(_ movie: MovieReviewElement) {
        let realmMyMovieInfomation = RealmMyMovieInfomation()
        let realm = try! Realm()
        
        realmMyMovieInfomation.title = movie.title
        realmMyMovieInfomation.reviewStars = movie.reviewStars
        realmMyMovieInfomation.releaseDay = movie.releaseDay
        realmMyMovieInfomation.overview = movie.overview
        realmMyMovieInfomation.review = movie.review
        realmMyMovieInfomation.movieImagePath = movie.movieImagePath
        
        try! realm.write {
            realm.add(realmMyMovieInfomation.self)
        }
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func fetchMovieReview() -> [MovieReviewElement] {
        var realmMyMovieInfomations: [RealmMyMovieInfomation] = []
        let realm = try! Realm()
         let fetchedMovies = realm.objects(RealmMyMovieInfomation.self)
        for movie in fetchedMovies {
            realmMyMovieInfomations.append(movie)
        }
        
        var movieReviewElements: [MovieReviewElement] = []
        for movie in realmMyMovieInfomations {
            movieReviewElements.append(MovieReviewElement(title: movie.title,
                                                          reviewStars: movie.reviewStars,
                                                          releaseDay: movie.releaseDay,
                                                          overview: movie.overview,
                                                          review: movie.review,
                                                          movieImagePath: movie.movieImagePath))
        }
        return movieReviewElements
    }
    
    func updateMovieReview(_ movie: MovieReviewElement) {
        let realmMyMovieInfomation = RealmMyMovieInfomation()
        let realm = try! Realm()
        
        try! realm.write {
            realmMyMovieInfomation.title = movie.title
            realmMyMovieInfomation.reviewStars = movie.reviewStars
            realmMyMovieInfomation.releaseDay = movie.releaseDay
            realmMyMovieInfomation.overview = movie.overview
            realmMyMovieInfomation.review = movie.review
            realmMyMovieInfomation.movieImagePath = movie.movieImagePath
        }

    }
    
    func deleteMovieReview(_ index: IndexPath) {
        let realm = try! Realm()
        let realmMyMovieInfomations = realm.objects(RealmMyMovieInfomation.self)
        
        try! realm.write {
            realm.delete(realmMyMovieInfomations[index.row])
        }
    }
    

    
}
