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
        mapVC.bottomSheetDidSnap(to: .tip, height: view.bounds.height - Const.bottomSheetYPosition(.tip))
    }
}

extension RootContainerViewController: CustomTabBarDelegate {
    func didSelectTab(_ tab: Buttons) {
        setMode(.medium)
        selectTab(tab)
        mapVC.bottomSheetDidSnap(to: .medium, height: view.bounds.height - Const.bottomSheetYPosition(.medium))
    }
}

extension RootContainerViewController: SearchViewControllerDelegate {
    func didSelectedPlace(place: Document) {
        let coordinate = (Double(place.x) ?? 0.0, Double(place.y) ?? 0.0)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateSheetState(.placeDetail(place))
            self.switchBottomSheet(PlaceDetailViewController())
            self.mapVC.moveToSelectedPlaceLocation(coordinate)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
