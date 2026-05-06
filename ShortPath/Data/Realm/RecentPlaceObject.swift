//
//  RecentPlaceObject.swift
//  ShortPath
//
//  Created by 선상혁 on 4/14/26.
//

import Foundation
import RealmSwift

final class RecentPlaceObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var placeId: String
    @Persisted var name: String
    @Persisted var category: String
    @Persisted var address: String
    @Persisted var roadAddress: String?
    @Persisted var longitude: Double
    @Persisted var latitude: Double
    @Persisted var phone: String?
    @Persisted var placeURL: String?
    @Persisted var searchedAt: Date
    
    convenience init(place: Place) {
        self.init()
        self.id = UUID().uuidString
        self.placeId = place.id
        self.name = place.name
        self.category = place.category
        self.address = place.address
        self.roadAddress = place.roadAddress
        self.longitude = place.longitude
        self.latitude = place.latitude
        self.phone = place.phone
        self.placeURL = place.placeURL
        self.searchedAt = Date()
    }
}

extension RecentPlaceObject {
    func toPlace() -> Place {
        Place(
            id: placeId,
            name: name,
            category: category,
            address: address,
            roadAddress: roadAddress,
            longitude: longitude,
            latitude: latitude,
            phone: phone,
            placeURL: placeURL
        )
    }
    
    func makeRecentPlaceItems(
        recentPlaces: [RecentPlaceObject],
        favoritePlaceIds: Set<String>
    ) -> [RecentPlaceItem] {
        recentPlaces.map { object in
            let place = object.toPlace()
            
            return RecentPlaceItem(
                id: object.id,
                place: place,
                searchedAt: object.searchedAt,
                isFavorite: favoritePlaceIds.contains(object.placeId)
            )
        }
    }
}
