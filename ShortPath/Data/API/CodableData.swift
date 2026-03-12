//
//  CodableData.swift
//  ShortPath
//
//  Created by 선상혁 on 2/15/26.
//

import Foundation

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
