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
    
    // identifier
    static let segueIdentifierForSave = "saveButtonTappedSegue"
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
    static let storeLocationAlertMessage = "保存先を選択してください"
    static let storeLocationAlertStockTitle = "後でレビューするに保存"
    static let storeLocationAlertReviewTitle = "レビューリストに保存"
    static let storeDateAlertMessage = "保存日を選択してください"
    static let storeDateAlertAddDateTitle = "追加した日で保存"
    static let storeDateAlertAddTodayTitle = "今日の日付で保存"

    // realm
    static let id = "id"
    
    // その他
    static let japanese = "ja"
    static let dateError = "未定"
}
