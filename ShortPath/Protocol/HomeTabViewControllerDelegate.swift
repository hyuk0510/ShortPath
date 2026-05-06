//
//  HomeTabViewControllerDelegate.swift
//  ShortPath
//
//  Created by 선상혁 on 4/15/26.
//

import Foundation

protocol HomeTabViewControllerDelegate: AnyObject {
    func didTapRecentRoute(_ recentRouteItem: RecentRouteItem)
    func moveToPlaceDetail(_ place: Place)
    func favoriteButtonPressed(_ recentPlaceItem: RecentPlaceItem)
    func moveToRouteEditing(_ place: Place)
    func calculatedDistance(_ recentRouteItem: RecentRouteItem) -> Int
    func pushSearchVCButtonPressed()
}
