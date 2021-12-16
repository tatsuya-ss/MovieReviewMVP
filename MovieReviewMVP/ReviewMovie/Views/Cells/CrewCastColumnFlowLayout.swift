//
//  CrewCastColumnFlowLayout.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/12/16.
//

import UIKit

final class CrewCastColumnFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        
        guard let cv = collectionView else { return }
        
        scrollDirection = .horizontal
        
        let cellHeight = cv.bounds.inset(by: cv.layoutMargins).size.height
                        
        let cellWidth = cellHeight * 27 / 35
                
        
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
    }
}
