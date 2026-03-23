//
//  RoutingViewModel.swift
//  ShortPath
//
//  Created by 선상혁 on 3/12/26.
//

import UIKit

final class RoutingViewModel {
    
    var onChange: (() -> Void)?
    
    private(set) var items: [RouteSectionItem] = [
        RouteSectionItem(placeId: nil, role: .start, place: nil),
        RouteSectionItem(placeId: nil, role: .destination, place: nil)
    ] {
        didSet {
            onChange?()
        }
    }
    
    var numberOfItems: Int {
        items.count
    }
    
    func items(at index: Int) -> RouteSectionItem {
        return items[index]
    }
    
    func setStartPlace(_ place: Place) {
        guard let firstIndex = items.indices.first else { return }
        items[firstIndex].place = place
    }
    
    func setWayPoint(_ place: Place) {
        addWayPoint()
        guard let lastIndex = items.lastIndex(where: { $0.role == .wayPoints }) else { return }
        items[lastIndex].place = place
    }

    func setEndPlace(_ place: Place) {
        guard let lastIndex = items.indices.last else { return }
        items[lastIndex].place = place
    }
    
    func addWayPoint() {
        guard let endIndex = items.firstIndex(where: { $0.role == .destination }) else { return }
        let wayPoint = RouteSectionItem(placeId: nil, role: .wayPoints, place: nil)
        items.insert(wayPoint, at: endIndex)
    }
    
    func updatePlace(_ place: Place, for id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].place = place
    }
    
    func swapStartDestination() {
        guard items.count >= 2 else { return }
        
        items[0].role = .destination
        items[items.count - 1].role = .start
        items.swapAt(0, items.count - 1)
    }
    
    func removeWayPoint(id: UUID) {
        items.removeAll { $0.id == id && $0.role == .wayPoints }
    }
    
    func clearPlace(for id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].place = nil
    }
    
    func resetItems() {
        items = [
            RouteSectionItem(placeId: nil, role: .start, place: nil),
            RouteSectionItem(placeId: nil, role: .destination, place: nil)
        ]
    }
    
    func moveItem(from source: Int, to destination: Int) {
        guard source != destination else { return }
        guard items.indices.contains(source), items.indices.contains(destination) else { return }
        
        let movedItem = items.remove(at: source)
        items.insert(movedItem, at: destination)
        
        reassignRoles()
    }
    
    func reassignRoles() {
        for index in items.indices {
            if index == 0 {
                items[index].role = .start
            } else if index == items.count - 1 {
                items[index].role = .destination
            } else {
                items[index].role = .wayPoints
            }
        }
    }
    
    func makeRouteDraft() -> RouteDraft? {
        guard items.count >= 2, let start = items.first?.place, let destination = items.last?.place else { return nil }
        
        let wayPoints = items.dropFirst().dropLast().compactMap { $0.place }
        
        return RouteDraft(start: start, waypoints: wayPoints, destination: destination)
    }
}
