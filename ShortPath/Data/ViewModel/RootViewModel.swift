//
//  RootViewModel.swift
//  ShortPath
//
//  Created by 선상혁 on 2/20/26.
//

import UIKit

final class RootViewModel {
    
    var sheetMode: SheetMode = .home
    
    func selectedPlace(_ place: Place) {
        sheetMode = .placeDetail(place)
    }
    
    func backToHome() {
        sheetMode = .home
    }
}
