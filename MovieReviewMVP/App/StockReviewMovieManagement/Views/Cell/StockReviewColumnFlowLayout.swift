//
//  StockReviewColumnFlowLayout.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/12/16.
//

import UIKit

final class StockReviewColumnFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        
        guard let cv = collectionView else { return }
        
        let availableWidth = cv.bounds.inset(by: cv.layoutMargins).size.width
        
        // 横幅狭いiPhone320 - cvのsafeAreaから離した幅20 - Cell同士の間隔5*2
        // 狭いiPhoneでも3つ表示したい
        let minColumnWidth = CGFloat(320 - 20 - 10) / 3
        
        let maxNumberColumns = Int(availableWidth / minColumnWidth)
        
        let cellWidth = (availableWidth / CGFloat(maxNumberColumns)).rounded(.down)
                
        let cellHeight = (cellWidth * 28 / 19) + 2 + 16
        
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
    }
}
