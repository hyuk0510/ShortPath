//
//  RouteDraft.swift
//  ShortPath
//
//  Created by 선상혁 on 3/6/26.
//

import Foundation

struct RouteDraft {
    var start: Place?
    var waypoints: [Place] = []
    var destination: Place?
    
    func routeCount() -> Int {
        return waypoints.count + 2
    }
}
