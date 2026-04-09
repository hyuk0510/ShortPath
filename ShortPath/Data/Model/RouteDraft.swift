//
//  RouteDraft.swift
//  ShortPath
//
//  Created by 선상혁 on 3/6/26.
//

import Foundation

struct RouteDraft: Equatable {
    var start: Place?
    var waypoints: [Place] = []
    var destination: Place?
    
    static func == (lhs: RouteDraft, rhs: RouteDraft) -> Bool {
        lhs.start?.id == rhs.start?.id &&
        lhs.waypoints.map(\.id) == rhs.waypoints.map(\.id) &&
        lhs.destination?.id == rhs.destination?.id
    }
}
