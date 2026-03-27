//
//  RouteRequestBody.swift
//  ShortPath
//
//  Created by 선상혁 on 3/27/26.
//

import Foundation

struct RouteRequestBody: Encodable {
    let origin: Points
    let destination: Points
    let waypoints: [Points]?
    let priority: String
}
