//
//  CurrentLocationRecentRouteRepositoryProtocol.swift
//  ShortPath
//
//  Created by 선상혁 on 9/1/26.
//

import Foundation

protocol CurrentLocationRecentRouteRepositoryProtocol {
    func saveCurrentLocationRecentRoute(destination: Place) throws
    func fetchAll() throws -> [CurrentLocationRecentRouteObject]
    func fetch(by id: String) throws -> CurrentLocationRecentRouteObject
    func delete(by id: String) throws
    func deleteAll() throws
    func updateCreatedAt(id: String, createdAt: Date) throws
}
