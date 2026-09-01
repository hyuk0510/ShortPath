//
//  RecentPlaceRepositoryProtocol.swift
//  ShortPath
//
//  Created by 선상혁 on 9/1/26.
//

import Foundation

protocol RecentPlaceRepositoryProtocol {
    func create(place: Place) throws
    func fetchAll() throws -> [RecentPlaceObject]
    func fetch(by id: String) throws -> RecentPlaceObject
    func delete(by id: String) throws
    func deleteAll() throws
    func updateViewedAt(id: String, viewedAt: Date) throws
}
