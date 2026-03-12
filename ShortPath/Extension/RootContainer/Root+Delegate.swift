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
    func didSelectedPlace(place: Place) {
        let coordinate = (Double(place.longitude), Double(place.latitude))
        let placeDetailVC = PlaceDetailViewController(place: place)
        
        placeDetailVC.delegate = self
                        
        navigationController?.popViewController(animated: true)

        DispatchQueue.main.async {
            self.showPlaceDetail(place: place, vc: placeDetailVC, coordinate: coordinate)
        }
        
    }
    
    func didDisappear() {
        mapVC.removePlaceDetailPoi()
    }
}

extension RootContainerViewController: PlaceDetailViewControllerDelegate {
    func closeButtonPressed() {
        self.updateSheetState(.home)
        self.selectTab(remainedTab ?? .home)
        self.navigationController?.pushViewController(self.searchVC, animated: false)
        mapVC.removePlaceDetailPoi()
    }
}
