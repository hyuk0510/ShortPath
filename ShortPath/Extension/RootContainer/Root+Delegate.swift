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
        let coordinate = (Double(place.longitude), Double(place.latitude))
        let placeDetailVC = PlaceDetailViewController(place: place)
        
        placeDetailVC.delegate = self
                        
        navigationController?.popViewController(animated: true)

        DispatchQueue.main.async {
            switch mode {
            case .main:
                self.showPlaceDetail(place: place, vc: placeDetailVC, coordinate: coordinate)
            case .routing(let targetID, _):
                self.routingViewModel.updatePlace(place, for: targetID)
            }
        }
        
    }
    
    func didDisappear(mode: SearchMode) {
        switch mode {
        case .main:
            updateSheetState(.home)
            mapVC.removePlaceDetailPoi()
        case .routing(_, _):
            break
        }
        navigationController?.popViewController(animated: false)
    }
}

extension RootContainerViewController: PlaceDetailViewControllerDelegate {
    func closeButtonPressed() {
        updateSheetState(.home)
        
        if let tab = remainedTab {
            selectTab(tab)
        } else {
            setMode(.tip, animated: false)
            customTabBar.deselectAll()
        }
        
        navigationController?.pushViewController(self.makeSearchVC(mode: .main), animated: false)
        mapVC.removePlaceDetailPoi()
    }
    
    func didSelectRouteAction(place: Place, action: RouteSection) {
        switch action {
        case .start:
            routingViewModel.setStartPlace(place)
        case .wayPoints:
            routingViewModel.setWayPoint(place)
        case .destination:
            routingViewModel.setEndPlace(place)
        }
        
        updateSheetState(.routing(.none))
        
        mapVC.moveToSelectedPlaceLocation((place.longitude, place.latitude), sheetMode: rootViewModel.currentSheetMode())
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
