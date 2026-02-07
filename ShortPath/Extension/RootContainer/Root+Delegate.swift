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
    }
}

extension RootContainerViewController: CustomTabBarDelegate {
    func didSelectTab(_ tab: Buttons) {
        setMode(.medium)
        selectTab(tab)
//        mapVC.bottomSheetDidSnap(to: .medium, height: view.bounds.height - Const.bottomSheetYPosition(.medium))
    }
}

extension RootContainerViewController: MapInitialLocationDelegate {
    func mapViewControllerDidReceivedInitialLocation(_ mapVC: MapViewController) {
        let bottomSheetHeight = view.bounds.height - Const.bottomSheetYPosition(.medium)
        
//        mapVC.bottomSheetDidSnap(to: .medium, height: bottomSheetHeight)
    }
}
