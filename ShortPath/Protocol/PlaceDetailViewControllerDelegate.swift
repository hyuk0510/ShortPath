//
//  PlaceDetailViewControllerDelegate.swift
//  ShortPath
//
//  Created by 선상혁 on 3/8/26.
//

import Foundation

protocol PlaceDetailViewControllerDelegate: AnyObject {
    func closeButtonPressed()
    func didSelectRouteAction(place: Place, action: RouteSection)
}
