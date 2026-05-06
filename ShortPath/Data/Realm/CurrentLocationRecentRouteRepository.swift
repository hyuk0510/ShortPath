//
//  CurrentLocationRecentRouteRepository.swift
//  ShortPath
//
//  Created by 선상혁 on 4/14/26.
//

import Foundation
import RealmSwift

enum RepositoryError: Error {
    case objectNotFound
    case invalidData
}

final class CurrentLocationRecentRouteRepository {
    static let shared = CurrentLocationRecentRouteRepository()
    
    private let realm: Realm
    private let limit: Int
    
    init(realm: Realm = try! Realm(), limit: Int = 10) {
        self.realm = realm
        self.limit = limit
    }
    
//    func saveRoute(_ destination: Place) {
//        let item = RecentRouteItem.currentLocationDestination(
//            CurrentLocationRecentRoute(
//                id: UUID().uuidString,
//                destination: destination,
//                createdAt: Date()))
//        let object = RecentPlaceObject(place: destination)
//        
//        do {
//            try realm.write {
//                realm.add(object, update: .modified)
//            }
//        } catch {
//            print("최근 사용한 경로(현재위치 -> 목적지) 저장 실패: \(error)")
//        }
//    }
    
    func saveCurrentLocationRecentRoute(destination: Place) throws {
        let route = CurrentLocationRecentRoute(
            id: UUID().uuidString,
            destination: destination,
            createdAt: Date()
        )
        
        let object = CurrentLocationRecentRouteObject(route: route)
        let duplicates = duplicateObjects(for: destination)
        
        try realm.write {
            realm.delete(duplicates)
            realm.add(object, update: .modified)
        }
        
        try trimIfNeeded()
    }
    
    func fetchAll() throws -> [CurrentLocationRecentRouteObject] {
        Array(
            realm.objects(CurrentLocationRecentRouteObject.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
        )
    }
    
    func fetch(by id: String) throws -> CurrentLocationRecentRouteObject {
        guard let object = realm.object(ofType: CurrentLocationRecentRouteObject.self, forPrimaryKey: id) else {
            throw RepositoryError.objectNotFound
        }
        return object
    }
    
    func delete(by id: String) throws {
        guard let object = realm.object(ofType: CurrentLocationRecentRouteObject.self, forPrimaryKey: id) else {
            throw RepositoryError.objectNotFound
        }
        
        try realm.write {
            realm.delete(object)
        }
    }
    
    func deleteAll() throws {
        let objects = realm.objects(CurrentLocationRecentRouteObject.self)
        
        try realm.write {
            realm.delete(objects)
        }
    }
    
    func updateCreatedAt(id: String, createdAt: Date) throws {
        let object = try fetch(by: id)
        
        try realm.write {
            object.createdAt = createdAt
        }
    }

    private func duplicateObjects(for destination: Place) -> [CurrentLocationRecentRouteObject] {
        let objects = realm.objects(CurrentLocationRecentRouteObject.self)
        
        if !destination.id.isEmpty {
            return Array(objects.filter("destinationPlaceId == %@", destination.id))
        }
        
        return objects.filter { object in
            object.destinationName == destination.name &&
            object.destinationLongitude == destination.longitude &&
            object.destinationLatitude == destination.latitude
        }
    }
    
    private func trimIfNeeded() throws {
        let objects = realm.objects(CurrentLocationRecentRouteObject.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
        
        guard objects.count > limit else { return }
        
        let extraObjects = Array(objects.dropFirst(limit))
        
        try realm.write {
            realm.delete(extraObjects)
        }
    }
}
