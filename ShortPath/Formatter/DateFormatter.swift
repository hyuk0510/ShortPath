//
//  DateFormatter.swift
//  ShortPath
//
//  Created by 선상혁 on 4/18/26.
//

import Foundation

extension DateFormatter {
    static let recentDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM.dd"
        
        return formatter
    }()
}
