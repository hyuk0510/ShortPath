//
//  FavoritePlace.swift
//  ShortPath
//
//  Created by 선상혁 on 3/31/26.
//

import Foundation
import RealmSwift

final class FavoritePlace: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String = ""
    @Persisted var category: String = ""
    @Persisted var address: String = ""
    @Persisted var roadAddress: String?
    @Persisted var longitude: Double = 0
    @Persisted var latitude: Double = 0
    @Persisted var phone: String?
    @Persisted var placeURL: String?
    @Persisted var createdAt = Date()
    
    convenience init(place: Place) {
        self.init()
        self.id = place.id
        self.name = place.name
        self.category = place.category
        self.address = place.address
        self.roadAddress = place.roadAddress
        self.longitude = place.longitude
        self.latitude = place.latitude
        self.phone = place.phone
        self.placeURL = place.placeURL
        self.createdAt = Date()
    }
}

extension FavoritePlace {
    func toPlace() -> Place {
        Place(id: id, name: name, category: category, address: address, roadAddress: roadAddress, longitude: longitude, latitude: latitude, distance: nil, phone: phone, placeURL: placeURL)
    }
}
