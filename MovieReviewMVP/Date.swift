//
//  Date.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/06/25.
//

import Foundation

struct DateFormat {
    let dateFormatter = DateFormatter()
    
    func convertDateToString(date: Date?) -> String {
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: .japanese)
        
        guard let date = date else { return .dateError }
        let dateString = " 登録日" + " " + dateFormatter.string(from: date)
        return dateString
    }
    
    func convertDateToStringForNavigationTitle(date: Date?) -> String {
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: .japanese)
        
        guard let date = date else { return .dateError }
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    
}
