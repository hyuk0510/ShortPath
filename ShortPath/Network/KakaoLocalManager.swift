//
//  KakaoLocalManager.swift
//  ShortPath
//
//  Created by 선상혁 on 2/13/26.
//

import Foundation
import CoreLocation

enum NetworkError: Error {
    case APIKeyError
    case invalidURL
    case invalidResponse
}

final class KakaoLocalManager {
    static let shared = KakaoLocalManager()
    
    func fetchKeywordSearch(text: String, coordinate: CLLocationCoordinate2D) async throws -> PlaceInfo  {
        var urlComponents = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword")
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: text),
            URLQueryItem(name: "x", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "y", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "sort", value: "distance")
        ]
        
        guard let url = urlComponents?.url else { throw NetworkError.invalidURL }
        
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("KakaoAK \(APIKey.kakaoAPI)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
                
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.APIKeyError
        }
        
        let result = try JSONDecoder().decode(PlaceInfo.self, from: data)
        
        return result
    }
    
    func fetchRoute(_ route: [RouteSectionItem]) async throws -> RoutePath {
        guard let url = URL(string: "https://apis-navi.kakaomobility.com/v1/waypoints/directions") else { throw NetworkError.invalidURL }
        
        var request: URLRequest = URLRequest(url: url)
        
        guard let startPlace = route.first(where: { $0.role == .start }) else { throw NetworkError.invalidResponse }
        guard let destination = route.first(where: { $0.role == .destination }) else { throw NetworkError.invalidResponse }
        
        let wayPoints = route.filter{ $0.role == .wayPoints}
        
        let origin = Points(name: startPlace.place?.name, x: startPlace.place?.longitude ?? 0, y: startPlace.place?.latitude ?? 0)
        
        let dest = Points(name: destination.place?.name, x: destination.place?.longitude ?? 0, y: destination.place?.latitude ?? 0)
        
        var wayPointArr: [Points] = []
        
        for wayPoint in wayPoints {
            let point = Points(name: wayPoint.place?.name, x: wayPoint.place?.longitude ?? 0, y: wayPoint.place?.latitude ?? 0)
            
            wayPointArr.append(point)
        }
        
        let body = RouteRequestBody(origin: origin, destination: dest, waypoints: wayPointArr, priority: "DISTANCE")
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("KakaoAK \(APIKey.kakaoAPI)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
                
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print(httpResponse.statusCode)
            throw NetworkError.APIKeyError
        }
        
        let result = try JSONDecoder().decode(RoutePath.self, from: data)
        
        return result
    }
}
