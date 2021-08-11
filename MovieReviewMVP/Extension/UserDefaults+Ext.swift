//
//  UserDefaults+Ext.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/08/12.
//

import Foundation

extension UserDefaults {
    func saveNumberOfSaves() { // 保存回数を+1して保存
        var numberOfSaves = self.loadNumberOfSaves()
        numberOfSaves += 1
        self.set(numberOfSaves, forKey: .numberOfSavesKey)
    }
    
    func loadNumberOfSaves() -> Int { // 保存回数を読み込み
        let numberOfSaves = self.integer(forKey: .numberOfSavesKey)
        return numberOfSaves
    }
}

private extension String {
    static let numberOfSavesKey = "numberOfSaves"
}
