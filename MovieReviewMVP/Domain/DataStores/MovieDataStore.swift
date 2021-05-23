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
                presenter.updateReviewMovies(.initial, nil)
                print("初期表示を行いました")
            case let .update(_, deletions, insertions, modifications):
                
                if let deletionIndex = deletions.first {
                    presenter.updateReviewMovies(.delete, deletionIndex)
                } else if let insertionIndex = insertions.first {
                    presenter.updateReviewMovies(.insert, insertionIndex)
                } else if let modificationIndex = modifications.first {
                    presenter.updateReviewMovies(.modificate, modificationIndex)
                }

                print("更新処理を行いました",deletions, insertions, modifications)
            case let .error(error):
                print(error)
            }
        }
    }
    
    
    func createMovieReview(_ movie: MovieReviewElement) {
        let realmMyMovieInfomation = RealmMyMovieInfomation()
        let realm = try! Realm()
        
        realmMyMovieInfomation.title = movie.title ?? ""
        realmMyMovieInfomation.reviewStars = movie.reviewStars ?? 0.0
        realmMyMovieInfomation.releaseDay = movie.releaseDay ?? ""
        realmMyMovieInfomation.overview = movie.overview ?? ""
        realmMyMovieInfomation.review = movie.review ?? ""
        realmMyMovieInfomation.movieImagePath = movie.poster_path ?? ""
        
        
        
        try! realm.write {
            realm.add(realmMyMovieInfomation.self)
            
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
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
            
            movieReviewElements.append(MovieReviewElement(title: movie.title, poster_path: movie.movieImagePath, original_name: movie.original_name, backdrop_path: movie.backdrop_path, overview: movie.overview, releaseDay: movie.releaseDay, reviewStars: movie.reviewStars, review: movie.review))
            
        }
        return movieReviewElements
    }
    
    func updateMovieReview(_ movie: MovieReviewElement) {
        
        let realmMyMovieInfomation = RealmMyMovieInfomation()
        realmMyMovieInfomation.title = movie.title ?? ""
        realmMyMovieInfomation.reviewStars = movie.reviewStars ?? 0.0
        realmMyMovieInfomation.releaseDay = movie.releaseDay ?? ""
        realmMyMovieInfomation.overview = movie.overview ?? ""
        realmMyMovieInfomation.review = movie.review ?? ""
        realmMyMovieInfomation.movieImagePath = movie.poster_path ?? ""

        let realm = try! Realm()
        
        try! realm.write {
            realm.add(realmMyMovieInfomation, update: .modified)
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
