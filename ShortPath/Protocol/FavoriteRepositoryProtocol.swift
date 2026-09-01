//
//  FavoriteRepositoryProtocol.swift
//  ShortPath
//
//  Created by 선상혁 on 9/1/26.
//

import Foundation

protocol FavoriteRepositoryProtocol {
    func savePlace(place: Place)
    func deletePlace(placeID: String)
    func isFavorite(placeID: String) -> Bool
    func fetchAlltoFavoritePlace() -> [FavoritePlace]
    func fetchAlltoPlace() -> [Place]
    func fetch(placeID: String) -> Place?
}
