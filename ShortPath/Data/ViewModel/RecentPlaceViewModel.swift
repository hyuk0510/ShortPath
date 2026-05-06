//
//  RecentRouteViewModel.swift
//  ShortPath
//
//  Created by 선상혁 on 4/15/26.
//

import UIKit
import RealmSwift

final class RecentPlaceViewModel {
    private let recentPlaceRepo = RecentPlaceRepository.shared
    private let favoritePlaceRepo = FavoriteRepository.shared
    
    func fetchRecentPlaceItems() throws -> [RecentPlaceItem] {
        let recentPlaces = try recentPlaceRepo.fetchAll()
        
        let favoritePlaceIds = Set(
            favoritePlaceRepo.fetchAlltoFavoritePlace().map{ $0.id }
        )
        
        return recentPlaces.compactMap { object in
            let place = object.toPlace()
            
            return RecentPlaceItem(
                id: object.id,
                place: place,
                searchedAt: object.searchedAt,
                isFavorite: favoritePlaceIds.contains(place.id)
            )
        }
    }
    
    func deleteItem(id: String) throws {
        try recentPlaceRepo.delete(by: id)
    }
    
    func deleteAll() throws {
        try recentPlaceRepo.deleteAll()
    }
    
    func toggleFavorite(place: Place) {
        if let _ = favoritePlaceRepo.fetch(placeID: place.id) {
            favoritePlaceRepo.deletePlace(placeID: place.id)
        } else {
            favoritePlaceRepo.savePlace(place: place)
        }
    }
}
