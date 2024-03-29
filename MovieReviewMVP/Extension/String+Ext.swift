//
//  String+Ext.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/24.
//

import Foundation

extension String {
    // UIKit
    static let saveButtonTitle = "保存"
    static let updateButtonTitle = "更新"
    static let editButtonTitle = "編集"
    static let reviewTitle = "レビュー"
    static let deselectTitle = "解除"
    static let selectTitle = "選択"
    static let searchLabelTitle = "検索結果"
    static let upcomingLabelTitle = "近日公開"
    static let searchTitle = "検索"
    static let setting = "設定"
    static let stock = "ストック"
    static let placeholderString = "レビューを入力してください"
    
    // sort
    static let createdKeyPath = "create_at"
    static let reviewStarKeyPath = "reviewStars"
    static let createdAscendTitle = "新しい順"
    static let createdDescendTitle = "古い順"
    static let reviewStarAscendTitle = "高評価順"
    static let reviewStarDescendTitle = "低評価順"
    static let sortMark = "⋁"
    
    // setImageSystemName
    static let trashImageSystemName = "trash"
    static let stockButtonImageSystemName = "square.and.pencil"
    static let checkImageName = "check"
    static let trashImage = "trash_image"
    static let stockImage = "stock_image"
    
    // identifier
    static let reviewMovieStoryboardName = "ReviewMovie"
    static let StockReviewMovieManagementStoryboardName = "StockReviewMovieManagement"
    static let reviewMovieNibName = "ReviewMovie"
    static let movieTableCellIdentifier = "MovieCell"
    
    // alert
    static let deleteAlertMessage = "選択したレビューを削除しますか？"
    static let deleteAlertTitle = "レビューを削除"
    static let cancelAlert = "キャンセル"
    static let notTitle = "タイトルがありません"
    static let storedAlertMessage = "既に保存されているレビューです"
    static let storedAlertCancelTitle = "閉じる"

    // Google Admob
    static let testAdUnitId = "ca-app-pub-3940256099942544/2934735716"
    static let AdUnitId = "ca-app-pub-3889534374234643/2516620302"
    
    // バージョン
    static let version = "バージョン"
    
    // その他
    static let japanese = "ja"
    static let dateError = "未定"
}
