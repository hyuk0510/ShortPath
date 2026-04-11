//
//  RouteDraft.swift
//  ShortPath
//
//  Created by 선상혁 on 3/6/26.
//

import Foundation

struct RouteDraft: Equatable {
    var start: RoutePlace?
    var waypoints: [RoutePlace] = []
    var destination: RoutePlace?
    
    static func == (lhs: RouteDraft, rhs: RouteDraft) -> Bool {
        lhs.start?.id == rhs.start?.id &&
        lhs.waypoints.map(\.id) == rhs.waypoints.map(\.id) &&
        lhs.destination?.id == rhs.destination?.id
    }
}

extension RouteDraft {
    
    func toPlaceObjects() -> [FavoriteRoutePlaceObject] {
        var results: [FavoriteRoutePlaceObject] = []
        var currentOrder = 0
        
        if let start {
            let object = FavoriteRoutePlaceObject()
            object.placeId = start.id
            object.name = start.placeName
            object.address = start.roadAddress
            object.longitude = start.longitude
            object.latitude = start.latitude
            object.roleRawValue = RouteSection.start.rawValue
            object.order = currentOrder
            results.append(object)
            currentOrder += 1
        }
        
        for waypoint in waypoints {
            let object = FavoriteRoutePlaceObject()
            object.placeId = waypoint.id
            object.name = waypoint.placeName
            object.address = waypoint.roadAddress
            object.longitude = waypoint.longitude
            object.latitude = waypoint.latitude
            object.roleRawValue = RouteSection.wayPoint.rawValue
            object.order = currentOrder
            results.append(object)
            currentOrder += 1
        }
        
        if let destination {
            let object = FavoriteRoutePlaceObject()
            object.placeId = destination.id
            object.name = destination.placeName
            object.address = destination.roadAddress
            object.longitude = destination.longitude
            object.latitude = destination.latitude
            object.roleRawValue = RouteSection.destination.rawValue
            object.order = currentOrder
            results.append(object)
        }
        
        return results
    }
    
    func makeTitle() -> String {
        guard let startName = start?.placeName,
              let destinationName = destination?.placeName else {
            return "저장된 루트"
        }
        
        return "\(startName) → \(destinationName)"
    }
}
