//
//  RecentPlaceRepository.swift
//  ShortPath
//
//  Created by 선상혁 on 4/14/26.
//

import Foundation
import RealmSwift

final class RecentPlaceRepository {
    static let shared = RecentPlaceRepository()
        
//    private init() {
//        do {
//            realm = try Realm()
//        } catch {
//            fatalError("Realm 초기화 실패: \(error)")
//        }
//    }
    private let realm: Realm
    private let limit: Int
    
    init(realm: Realm = try! Realm(), limit: Int = 30) {
        self.realm = realm
        self.limit = limit
    }
    
    func create(place: Place) throws {
        let duplicates = duplicateObjects(for: place)
        
        let object = RecentPlaceObject(place: place)
        
        object.id = UUID().uuidString
        object.searchedAt = Date()
        
        try realm.write {
            realm.delete(duplicates)
            realm.add(object, update: .modified)
        }
        
        try trimIfNeeded()
    }
    
    func fetchAll() throws -> [RecentPlaceObject] {
        Array(
            realm.objects(RecentPlaceObject.self)
                .sorted(byKeyPath: "searchedAt", ascending: false)
        )
    }
    
    func fetch(by id: String) throws -> RecentPlaceObject {
        guard let object = realm.object(ofType: RecentPlaceObject.self, forPrimaryKey: id) else {
            throw RepositoryError.objectNotFound
        }
        return object
    }
    
    func delete(by id: String) throws {
        guard let object = realm.object(ofType: RecentPlaceObject.self, forPrimaryKey: id) else {
            throw RepositoryError.objectNotFound
        }
        
        try realm.write {
            realm.delete(object)
        }
    }
    
    func deleteAll() throws {
        let objects = realm.objects(RecentPlaceObject.self)
        
        try realm.write {
            realm.delete(objects)
        }
    }
    
    func updateViewedAt(id: String, viewedAt: Date) throws {
        let object = try fetch(by: id)
        
        try realm.write {
            object.searchedAt = viewedAt
        }
    }
    
    private func duplicateObjects(for place: Place) -> [RecentPlaceObject] {
        let objects = realm.objects(RecentPlaceObject.self)
        
        if !place.id.isEmpty {
            return Array(objects.filter("placeId == %@", place.id))
        }
        
        return objects.filter { object in
            object.name == place.name &&
            object.longitude == place.longitude &&
            object.latitude == place.latitude
        }
    }
    
    private func trimIfNeeded() throws {
        let objects = realm.objects(RecentPlaceObject.self)
            .sorted(byKeyPath: "searchedAt", ascending: false)
        
        guard objects.count > limit else { return }
        
        let extraObjects = Array(objects.dropFirst(limit))
        
        try realm.write {
            realm.delete(extraObjects)
        }
    }
}
