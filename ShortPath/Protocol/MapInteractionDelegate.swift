//
//  MapInteractionDelegate.swift
//  ShortPath
//
//  Created by 선상혁 on 12/31/25.
//

import UIKit
import CoreLocation

enum MapInteractionType {
    case pan
    case zoom
    case tap
}

protocol MapInteractionDelegate: AnyObject {
    func didUpdateCurrentLocation(_ location: CLLocation)
    func mapDidReceiveUserInteraction(type: MapInteractionType)
    func favoritePoiTapped(place: Place)
}
