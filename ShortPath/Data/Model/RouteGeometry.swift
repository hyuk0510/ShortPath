//
//  RouteGeometry.swift
//  ShortPath
//
//  Created by 선상혁 on 4/11/26.
//

import Foundation

struct RoutePathPoint: Equatable, Hashable {
    let longitude: Double
    let latitude: Double
}

struct RouteBounds: Equatable, Hashable {
    let minLng: Double
    let minLat: Double
    let maxLng: Double
    let maxLat: Double
}

struct RouteGeometry {
    let pathPoints: [RoutePathPoint]
    let bounds: RouteBounds
    let distance: Int
}

enum RouteGeometryBuilder {
    static func make(from route: Route) -> RouteGeometry {
        let sections = route.sections
        let bound = route.summary.bound
        
        var pathPoints: [RoutePathPoint] = []
        
        for section in sections {
            for road in section.roads {
                let vertexes = road.vertexes
                var index = 0
                
                while index < vertexes.count - 1 {
                    let longitude = vertexes[index]
                    let latitude = vertexes[index + 1]
                    
                    pathPoints.append(
                        RoutePathPoint(
                            longitude: longitude,
                            latitude: latitude
                        )
                    )
                    
                    index += 2
                }
            }
        }
        
        let minLongitude = bound.minX
        let minLatitude = bound.minY
        let maxLongitude = bound.maxX
        let maxLatitude = bound.maxY
        
        
        let bounds = RouteBounds(
                minLng: minLongitude,
                minLat: minLatitude,
                maxLng: maxLongitude,
                maxLat: maxLatitude
            )
        
        
        return RouteGeometry(
            pathPoints: pathPoints,
            bounds: bounds,
            distance: route.summary.distance
        )
    }
}

enum FavoriteRouteObjectFactory {
    static func make(
        from draft: RouteDraft,
        title: String? = nil,
        geometry: RouteGeometry
    ) -> FavoriteRouteObject {
        let object = FavoriteRouteObject()

        object.id = UUID().uuidString
        object.title = title ?? draft.makeTitle()
        object.createdAt = Date()

        object.places.append(objectsIn: draft.toPlaceObjects())

        let bounds = geometry.bounds
        let boundsObject = RouteBoundsObject()
        
        boundsObject.minLongitude = bounds.minLng
        boundsObject.minLatitude = bounds.minLat
        boundsObject.maxLongitude = bounds.maxLng
        boundsObject.maxLatitude = bounds.maxLat
        object.bounds = boundsObject
        

        let pathPointObjects = geometry.pathPoints.map { point -> RoutePathPointObject in
            let object = RoutePathPointObject()
            object.longitude = point.longitude
            object.latitude = point.latitude
            return object
        }

        object.pathPoints.append(objectsIn: pathPointObjects)
        object.distance = geometry.distance

        return object
    }
}

extension Array where Element == RoutePathPoint {
    func toObjects() -> [RoutePathPointObject] {
        map { point in
            let object = RoutePathPointObject()
            object.longitude = point.longitude
            object.latitude = point.latitude
            return object
        }
    }
}

extension RouteBounds {
    func toObject() -> RouteBoundsObject {
        let object = RouteBoundsObject()
        object.minLongitude = minLng
        object.minLatitude = minLat
        object.maxLongitude = maxLng
        object.maxLatitude = maxLat
        return object
    }
}
