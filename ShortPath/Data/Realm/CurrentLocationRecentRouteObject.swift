//
//  CurrentLocationRecentRouteObject.swift
//  ShortPath
//
//  Created by 선상혁 on 4/14/26.
//

import Foundation
import RealmSwift

final class CurrentLocationRecentRouteObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var createdAt: Date
    @Persisted var destinationPlaceId: String
    @Persisted var destinationName: String
    @Persisted var destinationCategory: String
    @Persisted var destinationAddress: String
    @Persisted var destinationRoadAddress: String?
    @Persisted var destinationLongitude: Double
    @Persisted var destinationLatitude: Double
    @Persisted var destinationPhone: String?
    @Persisted var destinationPlaceURL: String?

    convenience init(route: CurrentLocationRecentRoute) {
        self.init()
        self.id = route.id
        self.createdAt = route.createdAt
        self.destinationPlaceId = route.destination.id
        self.destinationName = route.destination.name
        self.destinationCategory = route.destination.category
        self.destinationAddress = route.destination.address
        self.destinationRoadAddress = route.destination.roadAddress
        self.destinationLongitude = route.destination.longitude
        self.destinationLatitude = route.destination.latitude
        self.destinationPhone = route.destination.phone
        self.destinationPlaceURL = route.destination.placeURL
    }

    func toDomain() -> CurrentLocationRecentRoute {
        let destination = Place(
            id: destinationPlaceId,
            name: destinationName,
            category: destinationCategory,
            address: destinationAddress,
            roadAddress: destinationRoadAddress,
            longitude: destinationLongitude,
            latitude: destinationLatitude,
            phone: destinationPhone,
            placeURL: destinationPlaceURL
        )

        return CurrentLocationRecentRoute(
            id: id,
            destination: destination,
            createdAt: createdAt
        )
    }
}
