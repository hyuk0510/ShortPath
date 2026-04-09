//
//  PlaceDetailScene.swift
//  ShortPath
//
//  Created by 선상혁 on 4/5/26.
//

import Foundation

struct PlaceDetailScene: Equatable {
    let place: Place
    let style: PlaceDetailStyle
}

enum PlaceDetailStyle {
    case normal
    case pushBySearch
    case routeCandidate
}
