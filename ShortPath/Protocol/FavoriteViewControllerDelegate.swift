//
//  FavoriteViewControllerDelegate.swift
//  ShortPath
//
//  Created by 선상혁 on 4/11/26.
//

import Foundation

protocol FavoriteViewControllerDelegate: AnyObject {
    func didTabPlace()
    func didTabRoute()
    func calculatedDistance(_ coord: (longitude: Double, latitude: Double)) -> Int
    func didTabPlaceCell(_ place: FavoritePlace)
    func didTabRouteCell(_ route: FavoriteRouteObject)
    func removePlace(_ place: Place)
    func removeRoute(_ routeID: String)
}
