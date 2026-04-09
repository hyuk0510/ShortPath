//
//  FavoritesRepository.swift
//  ShortPath
//
//  Created by 선상혁 on 3/31/26.
//

import Foundation
import RealmSwift

final class FavoriteRepository {
    static let shared = FavoriteRepository()
    
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Realm 초기화 실패: \(error)")
        }
    }
    
    func savePlace(place: Place) {
        let object = FavoritePlace(place: place)
        
        do {
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch {
            print("즐겨찾기 장소 저장 실패: \(error)")
        }
    }
    
    func deletePlace(placeID: String) {
        guard let object = realm.object(ofType: FavoritePlace.self, forPrimaryKey: placeID) else { return }
        
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("즐겨찾기 장소 삭제 실패: \(error)")
        }
    }
    
    func isFavorite(placeID: String) -> Bool {
        realm.object(ofType: FavoritePlace.self, forPrimaryKey: placeID) != nil
    }
    
    func fetchAll() -> [Place] {
        realm.objects(FavoritePlace.self).sorted(byKeyPath: "createdAt", ascending: false).map{ $0.toPlace() }
    }
    
    func fetch(placeID: String) -> Place? {
        realm.object(ofType: FavoritePlace.self, forPrimaryKey: placeID)?.toPlace()
    }
    
}
