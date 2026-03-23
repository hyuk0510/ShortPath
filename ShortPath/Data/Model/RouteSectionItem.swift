//
//  RoutePointItem.swift
//  ShortPath
//
//  Created by 선상혁 on 3/14/26.
//

import Foundation

struct RouteSectionItem: Equatable {
    let id: UUID = UUID()
    let placeId: String?
    
    var role: RouteSection
    var place: Place?
}
