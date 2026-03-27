//
//  CodableData.swift
//  ShortPath
//
//  Created by 선상혁 on 2/15/26.
//

import Foundation

// KeyWord 검색 -> PlaceInfo

struct PlaceInfo: Codable {
    let documents: [Document]
    let meta: Meta
}

struct Document: Codable {
    let addressName, categoryGroupCode, categoryGroupName, categoryName: String
    let distance, id, phone, placeName: String
    let placeURL: String
    let roadAddressName, x, y: String
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case categoryGroupCode = "category_group_code"
        case categoryGroupName = "category_group_name"
        case categoryName = "category_name"
        case distance, id, phone
        case placeName = "place_name"
        case placeURL = "place_url"
        case roadAddressName = "road_address_name"
        case x, y
    }
}

struct Meta: Codable {
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
    }
}

extension Document {
    func toPlace() -> Place {
        Place(id: id, name: placeName, category: categoryName, address: addressName, roadAddress: roadAddressName.isEmpty ? nil : roadAddressName, longitude: Double(x) ?? 0, latitude: Double(y) ?? 0, distance: Int(distance), phone: phone.isEmpty ? nil : phone, placeURL: placeURL.isEmpty ? nil : placeURL)
    }
}

// Route 검색 -> RoutePath

struct RoutePath: Codable {
    let transID: String
    let routes: [Route]

    enum CodingKeys: String, CodingKey {
        case transID = "trans_id"
        case routes
    }
}

// MARK: - Route
struct Route: Codable {
    let resultCode: Int
    let resultMsg: String
    let summary: Summary
    let sections: [Section]

    enum CodingKeys: String, CodingKey {
        case resultCode = "result_code"
        case resultMsg = "result_msg"
        case summary, sections
    }
}

// MARK: - Section
struct Section: Codable {
    let distance, duration: Int
    let bound: Bound
    let roads: [Road]
    let guides: [Guide]
}

// MARK: - Bound
struct Bound: Codable {
    let minX, minY, maxX, maxY: Double

    enum CodingKeys: String, CodingKey {
        case minX = "min_x"
        case minY = "min_y"
        case maxX = "max_x"
        case maxY = "max_y"
    }
}

// MARK: - Guide
struct Guide: Codable {
    let name: String
    let x, y: Double
    let distance, duration, type: Int
    let guidance: String
    let roadIndex: Int

    enum CodingKeys: String, CodingKey {
        case name, x, y, distance, duration, type, guidance
        case roadIndex = "road_index"
    }
}

// MARK: - Road
struct Road: Codable {
    let name: String
    let distance, duration, trafficSpeed, trafficState: Int
    let vertexes: [Double]

    enum CodingKeys: String, CodingKey {
        case name, distance, duration
        case trafficSpeed = "traffic_speed"
        case trafficState = "traffic_state"
        case vertexes
    }
}

// MARK: - Summary
struct Summary: Codable {
    let origin, destination: Points
    let waypoints: [Points]?
    let priority: String
    let bound: Bound
    let fare: Fare
    let distance, duration: Int
}

// MARK: - Destination
struct Points: Codable {
    let name: String?
    let x, y: Double
}

// MARK: - Fare
struct Fare: Codable {
    let taxi, toll: Int
}

