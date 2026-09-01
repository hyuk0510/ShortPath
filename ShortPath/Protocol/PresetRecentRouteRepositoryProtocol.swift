//
//  PresetRecentRouteRepositoryProtocol.swift
//  ShortPath
//
//  Created by 선상혁 on 9/1/26.
//

import Foundation

protocol PresetRecentRouteRepositoryProtocol {
    func create(
        routeDraft: RouteDraft,
        bounds: RouteBounds?,
        pathPoints: [RoutePathPoint]
    ) throws
    func fetchAll() throws -> [PresetRecentRouteObject]
    func fetch(by id: String) throws -> PresetRecentRouteObject
    func delete(by id: String) throws
    func deleteAll() throws
    func update(
        id: String,
        routeDraft: RouteDraft,
        bounds: RouteBounds?,
        pathPoints: [RoutePathPoint]
    ) throws
    
}
