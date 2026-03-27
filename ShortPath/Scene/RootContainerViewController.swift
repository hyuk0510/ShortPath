//
//  RootContainerViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit
import SnapKit

enum SheetMode: Equatable {
    case home
    case placeDetail(Place)
    case routing
}

final class RootContainerViewController: UIViewController {
    
    let mapVC = MapViewController()
    let customTabBar = CustomTabBar()
    
    let bottomSheetViewContainer = BottomSheetView()
    let searchBarContainer = SearchBarContainerView()
    let routingContainer = RoutingPanelView()
    
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
}
