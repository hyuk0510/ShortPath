//
//  Root+Delegate.swift
//  ShortPath
//
//  Created by 선상혁 on 1/7/26.
//

import UIKit

extension RootContainerViewController: MapInteractionDelegate {
    func mapDidReceiveUserInteraction() {
        setMode(.tip)
        customTabBar.deselectAll()
        currentLocationButton.isSelected = false
        
        if !rootViewModel.isRouting {
            mapVC.bottomSheetDidSnap(to: .tip, to: rootViewModel.currentSheetMode(), height: view.bounds.height - Const.bottomSheetYPosition(.tip, .home))
        }
    }
    
    func favoritePoiTapped(place: Place) {
        var enrichedPlace = place
        
        if enrichedPlace.distance == nil,
           let currentLocation = mapVC.currentLocation {
            enrichedPlace.distance = DistanceCalculator.distance(
                from: (currentLocation.coordinate.longitude, currentLocation.coordinate.latitude),
                to: (enrichedPlace.longitude, enrichedPlace.latitude)
            )
        }
        
        rootViewModel.presentFavoritePoiDetail(place: enrichedPlace)
                
        switch rootViewModel.currentSheetMode() {
        case .home, .placeDetail(_):
            let scene = PlaceDetailScene(place: enrichedPlace, style: .normal)
            let coordinate = (Double(enrichedPlace.longitude), Double(enrichedPlace.latitude))
            let placeDetailVC = PlaceDetailViewController(scene: scene)
            
            placeDetailVC.delegate = self
            
            DispatchQueue.main.async {
                self.showPlaceDetail(scene: scene, vc: placeDetailVC, coordinate: coordinate)
            }
            
        case .routing(let routingMode):
            let scene = PlaceDetailScene(place: enrichedPlace, style: .routeCandidate)
            
            if routingMode != .editing {
                if scene.style == .routeCandidate {
                    backButtonContainer.isHidden = false
                    
                    let coordinate = (Double(enrichedPlace.longitude), Double(enrichedPlace.latitude))
                    let placeDetailVC = PlaceDetailViewController(scene: scene)
                                        
                    placeDetailVC.delegate = self
                    
                    DispatchQueue.main.async {
                        self.showPlaceDetail(scene: scene, vc: placeDetailVC, coordinate: coordinate)
                    }
                }
            }
        }
    }
}

extension RootContainerViewController: CustomTabBarDelegate {
    func didSelectTab(_ tab: Buttons) {
        setMode(.medium)
        selectTab(tab)
        remainedTab = tab
        mapVC.bottomSheetDidSnap(to: .medium, to: rootViewModel.currentSheetMode(), height: view.bounds.height - Const.bottomSheetYPosition(.medium, .home))
    }
}

extension RootContainerViewController: SearchViewControllerDelegate {
    func didSelectedPlace(place: Place, mode: SearchMode) {
        let scene = PlaceDetailScene(place: place, style: .normal)
        let coordinate = (Double(place.longitude), Double(place.latitude))
        let placeDetailVC = PlaceDetailViewController(scene: scene)
        
        placeDetailVC.delegate = self
                        
        navigationController?.popViewController(animated: true)

        DispatchQueue.main.async {
            switch mode {
            case .main:
                self.showPlaceDetail(scene: scene, vc: placeDetailVC, coordinate: coordinate)
            case .routing(let targetID, _):
                self.mapVC.moveToSelectedPlaceLocation(coordinate, sheetMode: self.rootViewModel.currentSheetMode())
                self.mapVC.createPlaceDetailPoi(coordinate: coordinate, placeName: place.name)
                self.routingViewModel.updatePlace(place, for: targetID)
            }
        }
        
    }
    
    func didDisappear(mode: SearchMode) {
        switch mode {
        case .main:
            updateSheetState(.home)
            
            if let tab = remainedTab {
                selectTab(tab)
            } else {
                setMode(.tip, animated: false)
                customTabBar.deselectAll()
            }
            
            mapVC.removePlaceDetailPoi()
        case .routing(_, _):
            break
        }
        
        navigationController?.popViewController(animated: false)
    }
}

extension RootContainerViewController: PlaceDetailViewControllerDelegate {
    func closeButtonPressed() {
        backButtonContainer.isHidden = true
        mapVC.removePlaceDetailPoi()
        
        guard let sheetMode = rootViewModel.previousSheetMode else {
            updateSheetState(.home)
            
            if let tab = remainedTab {
                selectTab(tab)
            } else {
                setMode(.tip, animated: false)
                customTabBar.deselectAll()
            }
            
            return
        }
        
        updateSheetState(sheetMode)
        
        if let tab = remainedTab {
            selectTab(tab)
        } else {
            setMode(.tip, animated: false)
            customTabBar.deselectAll()
        }
        
    }
    
    func didSelectRouteAction(place: Place, action: RouteSection) {
        backButtonContainer.isHidden = true
        
        switch action {
        case .start:
            routingViewModel.setStartPlace(place)
        case .wayPoint:
            routingViewModel.setWayPoint(place)
        case .destination:
            routingViewModel.setEndPlace(place)
        }
        
        if routingViewModel.canRouting {
            updateSheetState(.routing(.editing))
        } else {
            updateSheetState(.routing(.none))
        }
        mapVC.moveToSelectedPlaceLocation((place.longitude, place.latitude), sheetMode: rootViewModel.currentSheetMode())
    }
    
    func favoriteButtonPressed(place: Place, isFavorite: Bool) {
        mapVC.updateFavoritePoi(place, isFavorite: isFavorite)
    }
}

extension RootContainerViewController: RoutingPanelViewDelegate {
    func didCloseRoutingPanelView() {
        updateSheetState(.home)
        
        if let tab = remainedTab {
            selectTab(tab)
        } else {
            setMode(.tip, animated: false)
            customTabBar.deselectAll()
        }
        
        mapVC.resetMargin()
        mapVC.removeRoute()
        mapVC.removeRoutePois()
        mapVC.removePlaceDetailPoi()
    }
    
    
}
