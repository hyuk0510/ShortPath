//
//  RecentRouteItem.swift
//  ShortPath
//
//  Created by 선상혁 on 4/14/26.
//

import UIKit

enum RecentRouteItem: Hashable {
    case currentLocationDestination(CurrentLocationRecentRoute)
    case presetRoute(PresetRecentRoute)
    
    var createdAt: Date {
        switch self {
        case .currentLocationDestination(let route):
            return route.createdAt
        case .presetRoute(let route):
            return route.createdAt
        }
    }
    
    var titleText: String {
        switch self {
        case .currentLocationDestination(let route):
            return "\(route.destination.name)"
        case .presetRoute(let route):
            return route.routeDraft.makeShortTitle()
        }
    }
    
    var subtitleText: String? {
        switch self {
        case .currentLocationDestination:
            return nil
        case .presetRoute(let route):
            let count = route.routeDraft.waypoints.count
            return count > 0 ? "경유지 \(count)곳" : nil
        }
    }
    
}

struct CurrentLocationRecentRoute: Hashable {
    let id: String
    let destination: Place
    let createdAt: Date
}

struct PresetRecentRoute: Hashable, Equatable {
    let id: String
    let routeDraft: RouteDraft
    let bounds: RouteBounds?
    let pathPoints: [RoutePathPoint]
    let distance: Int
    let createdAt: Date
}
