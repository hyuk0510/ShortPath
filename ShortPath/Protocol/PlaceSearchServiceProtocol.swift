//
//  PlaceSearchServiceProtocol.swift
//  ShortPath
//
//  Created by 선상혁 on 9/1/26.
//

import CoreLocation

protocol PlaceSearchServiceProtocol {
    func fetchKeywordSearch(text: String, coordinate: CLLocationCoordinate2D) async throws -> PlaceInfo
}
