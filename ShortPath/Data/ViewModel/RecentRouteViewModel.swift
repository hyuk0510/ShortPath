//
//  RecentRouteViewModel.swift
//  ShortPath
//
//  Created by 선상혁 on 4/15/26.
//

import UIKit

final class RecentRouteViewModel {
    private let currentRouteRepo = CurrentLocationRecentRouteRepository.shared
    private let presetRouteRepo = PresetRecentRouteRepository.shared
    
    func fetchRecentRouteItems(limit: Int = 10) throws -> [RecentRouteItem] {
        let currentRoutes = try currentRouteRepo.fetchAll()
        let presetRoutes = try presetRouteRepo.fetchAll()
        
        var merged: [RecentRouteItem] = []
        
        for currentRoute in currentRoutes {
            let domain = currentRoute.toDomain()
            
            merged.append(RecentRouteItem.currentLocationDestination(domain))
        }
        
        for presetRoute in presetRoutes {
            let domain = presetRoute.toDomain()
            
            merged.append(RecentRouteItem.presetRoute(domain))
        }
        
        return merged
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }
    
    func delete(item: RecentRouteItem) throws {
        switch item {
        case .currentLocationDestination(let object):
            try currentRouteRepo.delete(by: object.id)
        case .presetRoute(let object):
            try presetRouteRepo.delete(by: object.id)
        }
    }
    
    func deleteAll() throws {
        try currentRouteRepo.deleteAll()
        try presetRouteRepo.deleteAll()
    }
}
