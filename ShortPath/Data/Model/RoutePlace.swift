//
//  RoutePlace.swift
//  ShortPath
//
//  Created by 선상혁 on 4/9/26.
//

import Foundation

struct RoutePlace: Hashable {
    let id: String
    let placeName: String
    let roadAddress: String
    let longitude: Double
    let latitude: Double
}

extension RoutePlace {
    func toPlace() -> Place {
        Place(
            id: id,
            name: placeName,
            category: "",
            address: "",
            roadAddress: roadAddress,
            longitude: longitude,
            latitude: latitude,
            phone: nil,
            placeURL: nil)
    }
}
