//
//  SearchViewModel.swift
//  ShortPath
//
//  Created by 선상혁 on 9/1/26.
//

import Foundation
import CoreLocation

final class SearchViewModel {
    
    private(set) var places: [Place] = [] {
        didSet {
            onChange?()
        }
    }
    
    var onChange: (() -> Void)?
    
    private let placeSearchService: PlaceSearchServiceProtocol
    private let favoritePlaceRepo: FavoriteRepositoryProtocol
    private var searchTask: Task<Void, Never>?
    
    init(
        placeSearchService: PlaceSearchServiceProtocol = KakaoLocalManager.shared,
        favoritePlaceRepo: FavoriteRepositoryProtocol = FavoriteRepository.shared
    ) {
        self.placeSearchService = placeSearchService
        self.favoritePlaceRepo = favoritePlaceRepo
    }
    
    func search(text: String, coordinate: CLLocation?) {
        searchTask?.cancel()
        
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else {
            places = []
            return
        }
        
        searchTask = Task { [weak self] in
            guard let self else { return }
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            guard let coord = coordinate else { return }
            
            do {
                let result = try await placeSearchService.fetchKeywordSearch(text: query, coordinate: coord.coordinate)
                guard !Task.isCancelled else { return }
                
                let mappedPlaces = result.documents.map { $0.toPlace() }
                let sortedPlaces = self.sortPlaces(mappedPlaces, query: query)
                
                await MainActor.run {
                    self.places = sortedPlaces
                }
            } catch {
                print(error)
            }
        }
    }
    
    
    func isFavorite(placeID: String) -> Bool {
        favoritePlaceRepo.isFavorite(placeID: placeID)
    }
    
    private func sortPlaces(_ places: [Place], query: String) -> [Place] {
        let normalizedQuery = normalize(query)
        
        return places.sorted { lhs, rhs in
            score(for: lhs, query: normalizedQuery) > score(for: rhs, query: normalizedQuery)
        }
    }
    
    private func score(for place: Place, query: String) -> Int {
        let name = normalize(place.name)
        let roadAddress = normalize(place.roadAddress ?? "")
        let address = normalize(place.address)
        
        if name.hasPrefix(query) { return 300 }
        if name.contains(query) { return 200 }
        if roadAddress.contains(query) { return 100 }
        if address.contains(query) { return 80 }
        
        return 0
    }
    
    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
    }
    
}
