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
        mapVC.bottomSheetDidSnap(to: .tip, to: viewModel.sheetMode, height: view.bounds.height - Const.bottomSheetYPosition(.tip, .home))
    }
}

extension RootContainerViewController: CustomTabBarDelegate {
    func didSelectTab(_ tab: Buttons) {
        setMode(.medium)
        selectTab(tab)
        remainedTab = tab
        mapVC.bottomSheetDidSnap(to: .medium, to: viewModel.sheetMode, height: view.bounds.height - Const.bottomSheetYPosition(.medium, .home))
    }
}

extension RootContainerViewController: SearchViewControllerDelegate {
    func didSelectedPlace(place: Document) {
        let coordinate = (Double(place.x) ?? 0.0, Double(place.y) ?? 0.0)
        let placeDetailVC = PlaceDetailViewController()
        
        placeDetailVC.place = place
                
        navigationController?.popViewController(animated: true)

        DispatchQueue.main.async {
            self.showPlaceDetail(place: place, vc: placeDetailVC, coordinate: coordinate)
        }
        
    }
    
    func didDisappear() {
        mapVC.removePlaceDetailPoi()
    }
}
