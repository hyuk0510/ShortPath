//
//  RecentPlaceItem.swift
//  ShortPath
//
//  Created by 선상혁 on 4/14/26.
//

import UIKit

struct RecentPlaceItem: Hashable {
    let id: String
    let place: Place
    let searchedAt: Date
    var isFavorite: Bool
}
