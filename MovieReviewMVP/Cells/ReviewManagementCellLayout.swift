//
//  ReviewManagementCellLayout.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/20.
//

import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        
        guard let cv = collectionView else { return }
        
        let availableWidth = cv.bounds.inset(by: cv.layoutMargins).size.width
        
        
        let minColumnWidth = CGFloat(100.0)
        
        let maxNumberColumns = Int(availableWidth / minColumnWidth)
        
        let cellWidth = (availableWidth / CGFloat(maxNumberColumns)).rounded(.down)
                
        let cellHeight = (cellWidth * 28 / 19) + 2 + 16
        
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        headerReferenceSize = CGSize(width: cv.bounds.width, height: 30)
    }
}

class StockColumnFlowLayout : UICollectionViewFlowLayout {
    
    override func prepare() {
        
        guard let cv = collectionView else { return }
        
        scrollDirection = .horizontal

        let cellheight = cv.bounds.height - 10
        let cellWidth = cellheight * 19 / 28

        self.itemSize = CGSize(width: cellWidth, height: cellheight)
        
    }
}

class StockReviewColumnFlowLayout: UICollectionViewFlowLayout {
    
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

