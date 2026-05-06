//
//  PresetRecentRouteRepository.swift
//  ShortPath
//
//  Created by 선상혁 on 4/14/26.
//

import Foundation
import RealmSwift

final class PresetRecentRouteRepository {
    static let shared = PresetRecentRouteRepository()
    
    private let realm: Realm
    private let limit: Int
    
    init(realm: Realm = try! Realm(), limit: Int = 10) {
        self.realm = realm
        self.limit = limit
    }
    
    func create(
        routeDraft: RouteDraft,
        bounds: RouteBounds?,
        pathPoints: [RoutePathPoint]
    ) throws {
        let object = PresetRecentRouteObject()
        
        object.id = UUID().uuidString
        object.createdAt = Date()
        object.start = routeDraft.start.map { RecentRoutePlaceObject(place: $0) }
        object.destination = routeDraft.destination.map { RecentRoutePlaceObject(place: $0) }
        object.waypoints.append(objectsIn: routeDraft.waypoints.map {
            RecentRoutePlaceObject(place: $0)
        })
        object.bounds = bounds?.toObject()
        object.pathPoints.append(objectsIn: pathPoints.toObjects())
        object.distance = routeDraft.distance
        
        try realm.write {
            realm.add(object, update: .modified)
        }
        
        try trimIfNeeded()
    }
    
    func fetchAll() throws -> [PresetRecentRouteObject] {
        Array(
            realm.objects(PresetRecentRouteObject.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
        )
    }
    
    func fetch(by id: String) throws -> PresetRecentRouteObject {
        guard let object = realm.object(ofType: PresetRecentRouteObject.self, forPrimaryKey: id) else {
            throw RepositoryError.objectNotFound
        }
        return object
    }
    
    func delete(by id: String) throws {
        guard let object = realm.object(ofType: PresetRecentRouteObject.self, forPrimaryKey: id) else {
            throw RepositoryError.objectNotFound
        }
        
        try realm.write {
            realm.delete(object)
        }
    }
    
    func deleteAll() throws {
        let objects = realm.objects(PresetRecentRouteObject.self)
        
        try realm.write {
            realm.delete(objects)
        }
    }
    
    func update(
        id: String,
        routeDraft: RouteDraft,
        bounds: RouteBounds?,
        pathPoints: [RoutePathPoint]
    ) throws {
        let object = try fetch(by: id)
        
        try realm.write {
            object.createdAt = Date()
    
            object.start = routeDraft.start.map { RecentRoutePlaceObject(place: $0) }
            
            object.waypoints.removeAll()
            object.waypoints.append(objectsIn: routeDraft.waypoints.map {
                RecentRoutePlaceObject(place: $0)
            })
            
            object.destination = routeDraft.destination.map { RecentRoutePlaceObject(place: $0) }
            
            object.bounds = bounds?.toObject()
            
            object.pathPoints.removeAll()
            object.pathPoints.append(objectsIn: pathPoints.toObjects())
        }
    }
    
    private func trimIfNeeded() throws {
        let objects = realm.objects(PresetRecentRouteObject.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
        
        guard objects.count > limit else { return }
        
        let extraObjects = Array(objects.dropFirst(limit))
        
        try realm.write {
            realm.delete(extraObjects)
        }
    }
}
