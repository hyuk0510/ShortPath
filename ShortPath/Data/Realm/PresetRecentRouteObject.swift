//
//  PresetRecentRouteObject.swift
//  ShortPath
//
//  Created by 선상혁 on 4/14/26.
//

import Foundation
import RealmSwift

final class PresetRecentRouteObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var createdAt: Date
    
    @Persisted var start: RecentRoutePlaceObject?
    @Persisted var waypoints: List<RecentRoutePlaceObject>
    @Persisted var destination: RecentRoutePlaceObject?
    
    @Persisted var bounds: RouteBoundsObject?
    @Persisted var pathPoints: List<RoutePathPointObject>
    @Persisted var distance: Int
    
    convenience init(route: PresetRecentRoute) {
        self.init()
        self.id = route.id
        self.createdAt = route.createdAt
        
        self.start = route.routeDraft.start.map { RecentRoutePlaceObject(place: $0) }
        self.destination = route.routeDraft.destination.map { RecentRoutePlaceObject(place: $0) }
        self.waypoints.append(objectsIn: route.routeDraft.waypoints.map { RecentRoutePlaceObject(place: $0) })
        
        self.bounds = route.bounds?.toObject()
        self.pathPoints.append(objectsIn: route.pathPoints.toObjects())
        self.distance = distance
    }
    
    func toDomain() -> PresetRecentRoute {
        let draft = RouteDraft(
            start: start?.toRoutePlace(),
            waypoints: waypoints.map { $0.toRoutePlace() },
            destination: destination?.toRoutePlace(),
            distance: distance
        )
        
        return PresetRecentRoute(
            id: id,
            routeDraft: draft,
            bounds: routeBounds,
            pathPoints: routePathPoints,
            distance: distance,
            createdAt: createdAt
        )
    }
}

final class RecentRoutePlaceObject: Object {
    @Persisted var placeId: String
    @Persisted var name: String
    @Persisted var address: String
    @Persisted var longitude: Double
    @Persisted var latitude: Double
    
    convenience init(place: RoutePlace) {
        self.init()
        self.placeId = place.id
        self.name = place.placeName
        self.address = place.roadAddress
        self.longitude = place.longitude
        self.latitude = place.latitude
    }
    
    func toRoutePlace() -> RoutePlace {
        RoutePlace(
            id: placeId,
            placeName: name,
            roadAddress: address,
            longitude: longitude,
            latitude: latitude
        )
    }
}

extension PresetRecentRouteObject {
    var routeBounds: RouteBounds? {
        guard let bounds else { return nil }
        
        return RouteBounds(
            minLng: bounds.minLongitude,
            minLat: bounds.minLatitude,
            maxLng: bounds.maxLongitude,
            maxLat: bounds.maxLatitude
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
    
    var formattedDistance: String {
        DistanceFormatter.string(from: distance)
    }
}
