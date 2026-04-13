//
//  RootContainerViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit
import SnapKit
import SwiftUI

final class RootContainerViewController: UIViewController {
    
    let mapVC = MapViewController()
    let customTabBar = CustomTabBar()
    
    let bottomSheetViewContainer = BottomSheetView()
    let searchBarContainer = UIView()
    
    let searchBar = SearchBarContainerView()
    let routeStartButton = RouteStartButton()
    let routeStartButtonContainerView: UIView = {
        let view = UIView()
        
        view.setShadow(3)
        
        return view
    }()
    
    var searchBarTrailingToButton: Constraint?
    var searchBarTrailingToSuperview: Constraint?
    
    let homeVC = HomeTabViewController()
    let favoriteVC = FavoriteTabViewController()
    let settingVC = {
        let vc = UIHostingController(rootView: SettingView())
        vc.view.backgroundColor = .clear
        
        return vc
    }()
    
    let routeSummaryContainer = RouteSummaryView()
    let routingContainer = RoutingPanelView()
    let routingBottomActionContainer = RoutingBottomActionView()
    
    let backButtonContainer = PlaceDetailVCBackButtonContainer()
    
    lazy var searchVC = SearchViewController(mode: .main)
    
    var currentLocationButton = CurrentLocationButton()
    
    var mode: Mode = .medium
    var currentBottomSheetVC: UIViewController?
    var remainedTab: Buttons?
    
    var bottomSheetPanGesture: UIPanGestureRecognizer?
    
    weak var trackedScrollView: UIScrollView?
    var isScrollDragged = false
    var scrollViewSheetStartTop: CGFloat = 0
    
    var dragStartTop: CGFloat = 0
    
    var routingContainerHeightConstraint: Constraint?
    var sheetTopConstraint: Constraint!
    
    let rootViewModel = RootViewModel()
    let routingViewModel = RoutingViewModel()
    
    var routeTask: Task<Void, Never>?
    
    let placeRepo = FavoriteRepository.shared
    let routeRepo = FavoriteRouteRepository.shared
}
