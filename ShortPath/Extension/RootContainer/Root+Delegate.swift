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
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.mapVC.isPanned = true
            self.mapVC.isGUIButtonActive = false
            self.mapVC.updateGuiUI()
            self.updateSheetState(.placeDetail(place))
            self.switchBottomSheet(PlaceDetailViewController())
            self.setMode(.medium)
            self.mapVC.moveToSelectedPlaceLocation(coordinate)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
