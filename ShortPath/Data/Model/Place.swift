//
//  Place.swift
//  ShortPath
//
//  Created by 선상혁 on 3/6/26.
//

import Foundation

struct Place: Equatable, Hashable {
    let id: String
    let name: String
    let category: String
    let address: String
    let roadAddress: String?
    let longitude: Double
    let latitude: Double
    var distance: Int?
    let phone: String?
    let placeURL: String?
}

extension Place {
    func toRoutePlace() -> RoutePlace {
        
        return RoutePlace(id: self.id, placeName: self.name, roadAddress: self.roadAddress ?? "", longitude: self.longitude, latitude: self.latitude)
    }
}
