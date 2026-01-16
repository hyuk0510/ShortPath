//
//  RootContainerViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit
import SnapKit

final class RootContainerViewController: UIViewController {
    
    private let mapVC = MapViewController()
    let customTabBar = CustomTabBar()
    private let bottomSheetViewContainer = BottomSheetView()
    private let searchBarContainer = SearchBarContainerView()
    
    private var currentBottomSheetVC: UIViewController?
        
    private var sheetTopConstraint: Constraint!
        
    private(set) var mode: Mode = .medium
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMap()
        setUpSearchBar()
        setUpBottomSheet()
        setUpTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
                
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        guard let nav = navigationController?.navigationBar else { return }
        nav.standardAppearance = appearance
        nav.scrollEdgeAppearance = appearance
        nav.isHidden = false
        
        self.navigationItem.titleView = searchBarContainer
    }
    
    private func setUpMap() {
        addChild(mapVC)
        view.addSubview(mapVC.view)
        mapVC.mapInterActiveDelegate = self
        
        mapVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        mapVC.didMove(toParent: self)
    }
    
    private func setUpTabBar() {
        let height: CGFloat = UIScreen.main.bounds.height - Const.bottomSheetYPosition(.tip) + view.safeAreaInsets.bottom
        
        view.addSubview(customTabBar)
        view.bringSubviewToFront(customTabBar)
        
        customTabBar.tabButtonDelegate = self
        
        customTabBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(height)
        }
    }
    
    private func setUpBottomSheet() {
        view.addSubview(bottomSheetViewContainer)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        bottomSheetViewContainer.addGestureRecognizer(panGesture)
                
        bottomSheetViewContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetViewContainer.layer.cornerRadius = 12
        bottomSheetViewContainer.layer.masksToBounds = false
        
        bottomSheetViewContainer.setShadow()

        bottomSheetViewContainer.snp.makeConstraints { make in
            sheetTopConstraint = make.top.equalToSuperview().offset(Const.bottomSheetYPosition(.medium)).constraint
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        selectTab(.home)
    }
    
    private func setUpSearchBar() {
        searchBarContainer.setShadow()
                
        searchBarContainer.onTap = {
            let vc = SearchViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc
    private func didPan(_ recognizer: UIPanGestureRecognizer) {
        let translationY = recognizer.translation(in: view).y
        let velocityY = recognizer.velocity(in: view).y
        let newY = sheetTopConstraint.layoutConstraints.first!.constant + translationY

        let clampedY = min(
            max(Const.bottomSheetYPosition(.max), newY),
            Const.bottomSheetYPosition(.tip)
        )
        
        switch recognizer.state {
        case .changed:
            sheetTopConstraint.update(offset: clampedY)
            view.layoutIfNeeded()
            recognizer.setTranslation(.zero, in: view)
            
        case .ended, .cancelled:
            let targetMode: Mode = nearestMode(currentTop: clampedY, currentMode: mode, velocityY: velocityY)
            setMode(targetMode)
            
        default:
            break
        }
    }
    
    func selectTab(_ tab: Buttons) {
        
        let targetVC: UIViewController
        
        switch tab {
        case .home:
            targetVC = HomeTabViewController()
        case .favorite:
            targetVC = FavoriteTabViewController()
        case .setting:
            targetVC = SettingTabViewController()
        }
        
        switchBottomSheet(targetVC)
    }
    
    private func switchBottomSheet(_ newVC: UIViewController) {
        if let current = currentBottomSheetVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        addChild(newVC)
        bottomSheetViewContainer.addSubview(newVC.view)
        newVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        newVC.didMove(toParent: self)
        
        currentBottomSheetVC = newVC
    }
    
    func moveBottomSheet(to targetMode: Mode) {
        let targetTop = Const.bottomSheetYPosition(targetMode)
                
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            self.sheetTopConstraint.update(offset: targetTop)
            self.view.layoutIfNeeded()
        }
    }
    
    func setMode(_ newMode: Mode, animated: Bool = true) {
        guard mode != newMode else { return }
        mode = newMode
        
        if newMode == .tip {
            customTabBar.deselectAll()
        }
        
        moveBottomSheet(to: newMode)
    }
    
    private func nearestMode(
        currentTop: CGFloat,
        currentMode: Mode,
        velocityY: CGFloat
    ) -> Mode {
        
        let maxTop = Const.bottomSheetYPosition(.max)
        let mediumTop = Const.bottomSheetYPosition(.medium)
        
        let margin: CGFloat = 5
        
        switch currentMode {
        case .max:
            if currentTop > maxTop + margin {
                return .medium
            }
            return .max
        case .medium:
            if currentTop < mediumTop - margin {
                return .max
            }
            if currentTop > mediumTop + margin {
                return .tip
            }
            return .medium
        case .tip:
            break
        }
    
        return currentMode
    }
}
