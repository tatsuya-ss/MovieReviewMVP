//
//  MovieDataStore.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/12.
//

import RealmSwift

struct MovieDataStore : MovieReviewRepository {
    
    func createMovieReview(_ movie: MovieReviewElement) {
        let realmMyMovieInfomation = RealmMyMovieInfomation()
        let realm = try! Realm()
        
        if movie.title == nil {
            realmMyMovieInfomation.title = movie.original_name ?? ""
        } else {
            realmMyMovieInfomation.title = movie.title ?? ""
        }
        realmMyMovieInfomation.reviewStars = movie.reviewStars ?? 0.0
        realmMyMovieInfomation.releaseDay = movie.releaseDay ?? ""
        realmMyMovieInfomation.overview = movie.overview ?? ""
        realmMyMovieInfomation.review = movie.review
        realmMyMovieInfomation.movieImagePath = movie.poster_path ?? ""
        realmMyMovieInfomation.created_at = movie.create_at ?? Date()
        realmMyMovieInfomation.id = movie.id
        realmMyMovieInfomation.isStoredAsReview = movie.isStoredAsReview ?? true
        realmMyMovieInfomation.media_type = movie.media_type
        
        try! realm.write {
            realm.add(realmMyMovieInfomation.self)
        }
        
        print(#function, realmMyMovieInfomation)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func fetchMovieReview(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement] {
            
        let realm = try! Realm()
        var fetchedMovies: Results<RealmMyMovieInfomation>
        if let isStoredAsReview = isStoredAsReview {
            fetchedMovies = realm.objects(RealmMyMovieInfomation.self).filter("isStoredAsReview = \(isStoredAsReview)").sorted(byKeyPath: sortState.keyPath, ascending: sortState.ascending)
        } else {
            fetchedMovies = realm.objects(RealmMyMovieInfomation.self).sorted(byKeyPath: sortState.keyPath, ascending: sortState.ascending)
        }
        
        var movieReviewElements: [MovieReviewElement] = []
        for movie in fetchedMovies {
            movieReviewElements.append(MovieReviewElement(movieInfomation: movie))
        }
        for movie in movieReviewElements {
            print(movie.title)
        }
        return movieReviewElements
    }
    
    func updateMovieReview(_ movie: MovieReviewElement) {
        print("更新処理\n\(movie)")
        let realmMyMovieInfomation = RealmMyMovieInfomation()
        realmMyMovieInfomation.title = movie.title ?? ""
        realmMyMovieInfomation.reviewStars = movie.reviewStars ?? 0.0
        realmMyMovieInfomation.releaseDay = movie.releaseDay ?? ""
        realmMyMovieInfomation.overview = movie.overview ?? ""
        realmMyMovieInfomation.review = movie.review
        realmMyMovieInfomation.movieImagePath = movie.poster_path ?? ""
        realmMyMovieInfomation.created_at = movie.create_at ?? Date()
        realmMyMovieInfomation.id = movie.id
        realmMyMovieInfomation.isStoredAsReview = movie.isStoredAsReview ?? true
        realmMyMovieInfomation.media_type = movie.media_type


        let realm = try! Realm()
        
        try! realm.write {
            realm.add(realmMyMovieInfomation, update: .modified)
        }

    }
    
    func deleteMovieReview(_ sortState: sortState, _ id: Int) {
        let realm = try! Realm()
        let realmMyMovieInfomations = realm.objects(RealmMyMovieInfomation.self).filter("id = \(id)")
        
        try! realm.write {
            print("***********削除しました******************************")
            print(realmMyMovieInfomations)
            realm.delete(realmMyMovieInfomations)
        }
    }
    
    
    func sortMovieReview(_ sortState: sortState, isStoredAsReview: Bool?) -> [MovieReviewElement] {
        let realm = try! Realm()
        var sortedStoreDate: Results<RealmMyMovieInfomation>

        
        if let isStoredAsReview = isStoredAsReview {
            sortedStoreDate = realm.objects(RealmMyMovieInfomation.self).filter("isStoredAsReview = \(isStoredAsReview)").sorted(byKeyPath: sortState.keyPath, ascending: sortState.ascending)
        } else {
            sortedStoreDate = realm.objects(RealmMyMovieInfomation.self).sorted(byKeyPath: sortState.keyPath, ascending: sortState.ascending)
        }
    
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
    
        self = MovieReviewElement(title: movieInfomation.title,
                                  poster_path: movieInfomation.movieImagePath,
                                  original_name: movieInfomation.original_name,
                                  backdrop_path: movieInfomation.backdrop_path,
                                  overview: movieInfomation.overview,
                                  releaseDay: movieInfomation.releaseDay,
                                  reviewStars: movieInfomation.reviewStars,
                                  review: movieInfomation.review,
                                  create_at: movieInfomation.created_at,
                                  id: movieInfomation.id,
                                  isStoredAsReview: movieInfomation.isStoredAsReview,
                                  media_type: movieInfomation.media_type)
    }
    
}

