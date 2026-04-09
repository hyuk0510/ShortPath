//
//  RootViewModel.swift
//  ShortPath
//
//  Created by 선상혁 on 2/20/26.
//

import UIKit


enum SheetMode: Equatable {
    case home
    case placeDetail(PlaceDetailScene)
    case routing(RoutingMode)
}

enum RoutingMode {
    case none
    case editing
    case ready
}


final class RootViewModel {
    
    private var sheetMode: SheetMode = .home
    
    var previousSheetMode: SheetMode?
    
    var isRouting: Bool {
        switch sheetMode {
        case .home, .placeDetail(_):
            return false
        case .routing(_):
            return true
        }
    }
    
    func currentSheetMode() -> SheetMode {
        return sheetMode
    }
    
    func selectedPlace(_ place: Place, _ style: PlaceDetailStyle) {
        previousSheetMode = nil
        sheetMode = .placeDetail(
            PlaceDetailScene(
                place: place,
                style: style
            )
        )
    }
    
    func presentFavoritePoiDetail(place: Place) {
        switch sheetMode {
        case .home:
            previousSheetMode = nil
            sheetMode = .placeDetail(
                PlaceDetailScene(
                    place: place,
                    style: .normal
                )
            )
        case .placeDetail(_):
            previousSheetMode = nil
            sheetMode = .placeDetail(
                PlaceDetailScene(
                    place: place,
                    style: .pushBySearch
                )
            )
        case .routing(.editing):
            break
        case .routing(.none), .routing(.ready):
            previousSheetMode = sheetMode
            sheetMode = .placeDetail(
                PlaceDetailScene(
                    place: place,
                    style: .routeCandidate
                )
            )
        }
    }
    
    func dismissPlaceDetail() {
        sheetMode = previousSheetMode ?? .home
        previousSheetMode = nil
    }
    
//    func applyRouteRole(_ role: RouteSection, with place: Place) {
//        guard let previousSheetMode else { return }
//        
//        switch previousSheetMode {
//        case .routing(.none):
//            var draft = RouteDraft()
//            draft.update(place: place, for: role)
//            sheetMode = .routing(.editing(draft))
//            
//        case .routing(.ready(let result)):
//            var draft = RouteDraft(result: result)
//            draft.update(place: place, for: role)
//            sheetMode = .routing(.editing(draft))
//            
//        case .routing(.editing(let draft)):
//            var updated = draft
//            updated.update(place: place, for: role)
//            sheetMode = .routing(.editing(updated))
//            
//        case .home, .placeDetail:
//            break
//        }
//        
//        self.previousSheetMode = nil
//    }
    
    func backToHome() {
        sheetMode = .home
    }
    
    func routingMode(_ routingMode: RoutingMode) {
        sheetMode = .routing(routingMode)
    }
}
