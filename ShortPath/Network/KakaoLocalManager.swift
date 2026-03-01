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
    
    func fetchData(text: String, coordinate: CLLocationCoordinate2D) async throws -> PlaceInfo  {
        var urlComponents = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword.json")
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: text),
            URLQueryItem(name: "x", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "y", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "sort", value: "distance")
        ]
        
        guard let url = urlComponents?.url else { throw NetworkError.invalidURL }
        
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("KakaoAK \(APIKey.kakaoAPI)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
//        print(String(data: data, encoding: .utf8) ?? "no body")
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.APIKeyError
        }
        
        let result = try JSONDecoder().decode(PlaceInfo.self, from: data)
        
        return result
    }
}
