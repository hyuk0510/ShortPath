//
//  FavoriteRouteRepository.swift
//  ShortPath
//
//  Created by 선상혁 on 4/9/26.
//

import Foundation
import RealmSwift

final class FavoriteRouteRepository {
    static let shared = FavoriteRouteRepository()
    
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Realm 초기화 실패: \(error)")
        }
    }
    
    func saveRoute(_ object: FavoriteRouteObject) {
        do {
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch {
            print("루트 저장 실패")
        }
    }
    
    func fetchAll() -> [FavoriteRouteObject] {
        Array(
            realm.objects(FavoriteRouteObject.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
        )
    }
    
    func fetch(id: String) -> FavoriteRouteObject? {
        realm.object(ofType: FavoriteRouteObject.self, forPrimaryKey: id)
    }
    
    func delete(id: String) throws {
        guard let object = fetch(id: id) else { return }
        
        try realm.write {
            realm.delete(object.pathPoints)
            realm.delete(object.places)
            realm.delete(object)
        }
    }
    
    func exists(draft: RouteDraft) -> Bool {
        fetchAll().contains { $0.routeDraft == draft }
    }
}
