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
    
    var mode: Mode = .medium
    var currentBottomSheetVC: UIViewController?
    
    var sheetTopConstraint: Constraint!
    
    let viewModel = RootViewModel()
}
