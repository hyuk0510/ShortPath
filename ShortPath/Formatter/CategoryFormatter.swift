//
//  CategoryFormatter.swift
//  ShortPath
//
//  Created by 선상혁 on 3/12/26.
//

import Foundation

struct CategoryFormatter {
    static func string(from category: String) -> String {
        let arr = category.split(separator: " > ")
        
        return arr.count >= 3 ? String(arr[2]) : String(arr.last ?? "")
    }
}
