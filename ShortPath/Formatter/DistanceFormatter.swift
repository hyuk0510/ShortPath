//
//  DistanceFormatter.swift
//  ShortPath
//
//  Created by 선상혁 on 3/6/26.
//

import UIKit
import CoreLocation

struct DistanceFormatter {
    static func string(from distance: Int) -> String {
        if distance >= 1000 {
            return String(format: "%.1fkm", Double(distance) / 1000)
        } else {
            return "\(distance)m"
        }
    }
    
    static func string(from distance: String) -> String {
        let value = Int(distance) ?? 0
        return string(from: value)
    }
}

struct DistanceCalculator {
    static func distance(from: (longitude: Double, latitude: Double), to: (longitude: Double, latitude: Double)) -> Int {
        let distance = CLLocation(latitude: to.latitude, longitude: to.longitude).distance(from: CLLocation(latitude: from.latitude, longitude: from.longitude))
        
        return Int(distance)
    }
}
