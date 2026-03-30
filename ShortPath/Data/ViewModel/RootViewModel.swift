//
//  RootViewModel.swift
//  ShortPath
//
//  Created by 선상혁 on 2/20/26.
//

import UIKit

final class RootViewModel {
    
    private var sheetMode: SheetMode = .home
    
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
    
    func selectedPlace(_ place: Place) {
        sheetMode = .placeDetail(place)
    }
    
    func backToHome() {
        sheetMode = .home
    }
    
    func routingMode(_ routingMode: RoutingMode) {
        sheetMode = .routing(routingMode)
    }
}
