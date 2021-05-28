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
        // １回しか呼ばれてない
        let results = realm.objects(RealmMyMovieInfomation.self).sorted(byKeyPath: presenter.returnSortState().keyPath)

        print("NotificationのsortState → \(presenter.returnSortState())")
        print("通知受け取り時の\(results)")
        
        notificationToken = results.observe { changes in
            switch changes {
            
            case .initial:
                presenter.fetchUpdateReviewMovies(.initial)
                print("初期表示を行いました")
                
            case let .update(_, deletions, insertions, modifications):
                if deletions.first != nil {
//                    presenter.deleteReviewMovies(.delete)
                    print("削除しました")
                    
                } else if insertions.first != nil {
                    presenter.fetchUpdateReviewMovies(.insert)
                    
                } else if modifications.first != nil {
                    presenter.fetchUpdateReviewMovies(.modificate)
                    
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
        realmMyMovieInfomation.created_at = movie.create_at ?? Date()
        
        
        try! realm.write {
            realm.add(realmMyMovieInfomation.self)
            
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func fetchMovieReview(_ sortState: sortState) -> [MovieReviewElement] {
            
        let realm = try! Realm()
        
        let fetchedMovies = realm.objects(RealmMyMovieInfomation.self).sorted(byKeyPath: sortState.keyPath, ascending: sortState.ascending)
        
        var movieReviewElements: [MovieReviewElement] = []
        
        for movie in fetchedMovies {
            movieReviewElements.append(MovieReviewElement(movieInfomation: movie))
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
        realmMyMovieInfomation.created_at = movie.create_at ?? Date()

        let realm = try! Realm()
        
        try! realm.write {
            realm.add(realmMyMovieInfomation, update: .modified)
        }

    }
    
    func deleteMovieReview(_ sortState: sortState, _ index: IndexPath) {
        let realm = try! Realm()
        let realmMyMovieInfomations = realm.objects(RealmMyMovieInfomation.self).sorted(byKeyPath: sortState.keyPath, ascending: sortState.ascending)
        
        try! realm.write {
            print(realmMyMovieInfomations[index.row])
            realm.delete(realmMyMovieInfomations[index.row])
        }
    }
    
    
    func sortMovieReview(_ sortState: sortState) -> [MovieReviewElement] {
        let realm = try! Realm()
        
        let sortedStoreDate = realm.objects(RealmMyMovieInfomation.self).sorted(byKeyPath: sortState.keyPath, ascending: sortState.ascending)
    
        var movieReviewElements: [MovieReviewElement] = []
        
        for movie in sortedStoreDate {
            movieReviewElements.append(MovieReviewElement(movieInfomation: movie))
        }
        
        return movieReviewElements

    }
    
    
}

// MARK: Realm型をMovieReviewElementに変換
private extension MovieReviewElement {
    init(movieInfomation: RealmMyMovieInfomation) {
    
        self = MovieReviewElement(title: movieInfomation.title, poster_path: movieInfomation.movieImagePath, original_name: movieInfomation.original_name, backdrop_path: movieInfomation.backdrop_path, overview: movieInfomation.overview, releaseDay: movieInfomation.releaseDay, reviewStars: movieInfomation.reviewStars, review: movieInfomation.review, create_at: movieInfomation.created_at)
    }
    
}

