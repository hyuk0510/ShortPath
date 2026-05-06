//
//  FavoriteRouteObject.swift
//  ShortPath
//
//  Created by 선상혁 on 4/9/26.
//

import Foundation
import RealmSwift

final class FavoriteRouteObject: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString

    @Persisted var title: String
    @Persisted var createdAt: Date
    
    @Persisted var places: List<FavoriteRoutePlaceObject>
    
    @Persisted var bounds: RouteBoundsObject?
    @Persisted var pathPoints: List<RoutePathPointObject>
    @Persisted var distance: Int
}

final class FavoriteRoutePlaceObject: Object {
    @Persisted var placeId: String = ""
    @Persisted var name: String = ""
    @Persisted var address: String?
    @Persisted var longitude: Double = 0
    @Persisted var latitude: Double = 0
    @Persisted var roleRawValue: String = ""
    @Persisted var order: Int = 0
}

final class RouteBoundsObject: EmbeddedObject {
    @Persisted var minLongitude: Double = 0
    @Persisted var minLatitude: Double = 0
    @Persisted var maxLongitude: Double = 0
    @Persisted var maxLatitude: Double = 0
}

final class RoutePathPointObject: Object {
    @Persisted var longitude: Double
    @Persisted var latitude: Double
}

extension FavoriteRouteObject {
    var routeDraft: RouteDraft {
        let sortedPlaces = places.sorted { $0.order < $1.order }
        
        let start = sortedPlaces
            .first(where: { $0.roleRawValue == RouteSection.start.rawValue })?
            .toRoutePlace()
        
        let waypoints = sortedPlaces
            .filter { $0.roleRawValue == RouteSection.wayPoint.rawValue }
            .sorted { $0.order < $1.order }
            .map { $0.toRoutePlace() }
        
        let destination = sortedPlaces
            .first(where: { $0.roleRawValue == RouteSection.destination.rawValue })?
            .toRoutePlace()
        
        return RouteDraft(
            start: start,
            waypoints: waypoints,
            destination: destination,
            distance: distance
        )
    }
    
    var routePathPoints: [RoutePathPoint] {
        pathPoints.map {
            RoutePathPoint(
                longitude: $0.longitude,
                latitude: $0.latitude
            )
        }
    }
    
    var routeBounds: RouteBounds? {
        guard let bounds else { return nil }
        
        return RouteBounds(
            minLng: bounds.minLongitude,
            minLat: bounds.minLatitude,
            maxLng: bounds.maxLongitude,
            maxLat: bounds.maxLatitude
        )
    }
}


extension FavoriteRoutePlaceObject {
    func toRoutePlace() -> RoutePlace {
        return RoutePlace(id: placeId, placeName: name, roadAddress: address ?? "", longitude: longitude, latitude: latitude)
    }
}
