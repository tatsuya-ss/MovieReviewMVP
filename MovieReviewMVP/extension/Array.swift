//
//  Array.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/18.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(value: Element) {
        if let i = self.firstIndex(of: value) {
            self.remove(at: i)
        }
    }
}
