//
//  RootContainerViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit
import SnapKit

enum SheetMode {
    case home
    case placeDetail(Document)
}

final class RootContainerViewController: UIViewController {
    
    let mapVC = MapViewController()
    let customTabBar = CustomTabBar()
    let bottomSheetViewContainer = BottomSheetView()
    let searchBarContainer = SearchBarContainerView()
    lazy var searchVC = SearchViewController()
    
    var currentLocationButton = CurrentLocationButton()
    
    var mode: Mode = .medium
    var currentBottomSheetVC: UIViewController?
    var remainedTab: Buttons?
    
    var bottomSheetPanGesture: UIPanGestureRecognizer?
    
    weak var trackedScrollView: UIScrollView?
    var isScrollDragged = false
    var scrollViewSheetStartTop: CGFloat = 0
    
    var dragStartTop: CGFloat = 0
    
    var sheetTopConstraint: Constraint!
    
    let viewModel = RootViewModel()
}
