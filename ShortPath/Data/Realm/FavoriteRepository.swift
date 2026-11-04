//
//  FavoritesRepository.swift
//  ShortPath
//
//  Created by 선상혁 on 3/31/26.
//

import Foundation
import RealmSwift

final class FavoriteRepository: FavoriteRepositoryProtocol {
    static let shared = FavoriteRepository()
    static let defaultFolderName = "기본"

    private let realm: Realm

    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Realm 초기화 실패: \(error)")
        }

        seedDefaultFolder()
    }

    // "기본" 폴더가 항상 존재하도록 앱 시작 시 보장
    private func seedDefaultFolder() {
        guard realm.object(ofType: FavoriteFolder.self, forPrimaryKey: Self.defaultFolderName) == nil else { return }

        do {
            try realm.write {
                realm.add(FavoriteFolder(name: Self.defaultFolderName))
            }
        } catch {
            print("기본 폴더 생성 실패: \(error)")
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

    func fetchAlltoFavoritePlace() -> [FavoritePlace] {
        realm.objects(FavoritePlace.self).sorted(byKeyPath: "createdAt", ascending: false).map { $0 }
    }

    func fetchAlltoPlace() -> [Place] {
        realm.objects(FavoritePlace.self).sorted(byKeyPath: "createdAt", ascending: false).map { $0.toPlace() }
    }

    func fetch(placeID: String) -> Place? {
        realm.object(ofType: FavoritePlace.self, forPrimaryKey: placeID)?.toPlace()
    }

    func updateFolder(placeID: String, folderName: String) {
        guard let object = realm.object(ofType: FavoritePlace.self, forPrimaryKey: placeID) else { return }

        do {
            try realm.write {
                if realm.object(ofType: FavoriteFolder.self, forPrimaryKey: folderName) == nil {
                    realm.add(FavoriteFolder(name: folderName))
                }
                object.folderName = folderName
            }
        } catch {
            print("폴더 지정 실패: \(error)")
        }
    }

    func fetchAllFolderNames() -> [String] {
        realm.objects(FavoriteFolder.self)
            .sorted(byKeyPath: "createdAt", ascending: true)
            .map { $0.name }
    }

    func fetchPlaces(inFolder folderName: String) -> [Place] {
        realm.objects(FavoritePlace.self)
            .filter("folderName == %@", folderName)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .map { $0.toPlace() }
    }

    func createFolder(name: String) {
        guard realm.object(ofType: FavoriteFolder.self, forPrimaryKey: name) == nil else { return }

        do {
            try realm.write {
                realm.add(FavoriteFolder(name: name))
            }
        } catch {
            print("폴더 생성 실패: \(error)")
        }
    }

    func deleteFolder(name: String) {
        guard name != Self.defaultFolderName else { return }
        guard let folder = realm.object(ofType: FavoriteFolder.self, forPrimaryKey: name) else { return }

        let placesInFolder = realm.objects(FavoritePlace.self).filter("folderName == %@", name)

        do {
            try realm.write {
                placesInFolder.forEach { $0.folderName = Self.defaultFolderName }
                realm.delete(folder)
            }
        } catch {
            print("폴더 삭제 실패: \(error)")
        }
    }
}
