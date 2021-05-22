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
        
        let availavleWidth = cv.bounds.inset(by: cv.layoutMargins).size.width
        
        
        let minColumnWidth = CGFloat(100.0)
        
        let maxNumberColumns = Int(availavleWidth / minColumnWidth)
        
        let cellWidth = (availavleWidth / CGFloat(maxNumberColumns)).rounded(.down)
                
        let cellHeight = (cellWidth * 28 / 19) + 2 + 16
        
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
    }
}
