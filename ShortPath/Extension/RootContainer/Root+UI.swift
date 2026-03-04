//
//  Root+UI.swift
//  ShortPath
//
//  Created by 선상혁 on 2/17/26.
//

import UIKit

extension RootContainerViewController {
    
    func setUpMap() {
        addChild(mapVC)
        view.addSubview(mapVC.view)
        mapVC.mapInterActiveDelegate = self

        mapVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        mapVC.didMove(toParent: self)
    }
    
    func setUpTabBar() {
        let height: CGFloat = UIScreen.main.bounds.height - Const.bottomSheetYPosition(.tip, .home) + view.safeAreaInsets.bottom
        
        view.addSubview(customTabBar)
        view.bringSubviewToFront(customTabBar)
        
        customTabBar.tabButtonDelegate = self
        
        customTabBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(height)
        }
    }
    
    func setUpBottomSheet() {
        view.addSubview(bottomSheetViewContainer)
        
        bottomSheetPanGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        
        guard let bottomSheetPanGesture = bottomSheetPanGesture else { return }
        
        bottomSheetPanGesture.cancelsTouchesInView = false
        
        bottomSheetViewContainer.addGestureRecognizer(bottomSheetPanGesture)
                
        bottomSheetViewContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetViewContainer.layer.cornerRadius = 12
        bottomSheetViewContainer.layer.masksToBounds = false
        
        bottomSheetViewContainer.setShadow()

        bottomSheetViewContainer.snp.makeConstraints { make in
            sheetTopConstraint = make.top.equalToSuperview().offset(Const.bottomSheetYPosition(.medium, .home)).constraint
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        selectTab(.home)
    }
    
    func setUpSearchBar() {
        view.addSubview(searchBarContainer)
        searchBarContainer.setShadow()
                
        searchBarContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        searchVC.delegate = self
        
        searchBarContainer.onTap = {
            self.searchVC.coordinate = self.mapVC.currentLocation
            self.navigationController?.pushViewController(self.searchVC, animated: true)
        }

    }
    
    func setUpCurrentLocationButton() {
        view.addSubview(currentLocationButton)
        
        currentLocationButton.isSelected = true
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonPressed(_:)), for: .touchUpInside)
        
        currentLocationButton.snp.makeConstraints { make in
            make.bottom.equalTo(bottomSheetViewContainer.snp.top).offset(-16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.width.height.equalTo(48)
        }
    }
    
    @objc
    func currentLocationButtonPressed(_ sender: UIButton) {
        sender.isSelected = true
        mapVC.isPanned = false
        mapVC.moveCameraToCurrentLocation()
    }
    
    @objc
    func didPan(_ recognizer: UIPanGestureRecognizer) {
        let translationY = recognizer.translation(in: view).y
        let velocityY = recognizer.velocity(in: view).y
        let newY = sheetTopConstraint.layoutConstraints.first!.constant + translationY

        let clampedY = min(
            max(Const.bottomSheetYPosition(.max, viewModel.sheetMode), newY),
            Const.bottomSheetYPosition(.tip, viewModel.sheetMode)
        )
        
        switch recognizer.state {
        case .changed:
            sheetTopConstraint.update(offset: clampedY)
            view.layoutIfNeeded()
            
            let bottomSheetheight = view.bounds.height - clampedY
            
            if case .home = viewModel.sheetMode {
                if mode != .max, !mapVC.isPanned {
                    mapVC.updateBottomMargin(bottomSheetHeight: bottomSheetheight)
                    mapVC.moveCameraToCurrentLocation()
                }
            }
                        
            recognizer.setTranslation(.zero, in: view)
            
        case .ended, .cancelled:
            let targetMode: Mode = nearestMode(currentTop: clampedY, currentMode: mode, velocityY: velocityY)
            
            mapVC.bottomSheetDidSnap(to: targetMode, to: viewModel.sheetMode, height: view.bounds.height - Const.bottomSheetYPosition(targetMode, viewModel.sheetMode))
            if targetMode == .max {
                if !mapVC.isPanned {
                    mapVC.resetMargin()
                    mapVC.moveCameraToCurrentLocation()
                }
                
                if velocityY < 0 {
                    guard let vc = currentBottomSheetVC as? BottomSheetInteractable else { return }
                    vc.trackingScrollView?.isScrollEnabled = true
                }
            }
            
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
    
    func switchBottomSheet(_ newVC: UIViewController) {
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
        scrollViewTracking()
    }
    
    func moveBottomSheet(to targetMode: Mode) {
        let targetTop = Const.bottomSheetYPosition(targetMode, viewModel.sheetMode)
        
        UIView.animate(
            withDuration: 0.5,
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
        
        currentLocationButton.isHidden = newMode == .max ? true : false
        
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
        
        let maxTop = Const.bottomSheetYPosition(.max, viewModel.sheetMode)
        let mediumTop = Const.bottomSheetYPosition(.medium, viewModel.sheetMode)
        let minTop = Const.bottomSheetYPosition(.tip, viewModel.sheetMode)
        
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
            if currentTop < minTop - margin {
                return .medium
            }
            return .tip
        }
    
    }
    
    func updateSheetState(_ newMode: SheetMode) {
        viewModel.sheetMode = newMode
        render()
    }
    
    func render() {
        switch viewModel.sheetMode {
        case .home:
            customTabBar.isHidden = false
            searchBarContainer.configureHome()
            
        case .placeDetail(let document):
            searchBarContainer.configurePlaceDetail(document)
            customTabBar.isHidden = true
            
            searchBarContainer.onTap = { [weak self] in
                guard let self = self else { return }

                self.updateSheetState(.home)
                self.selectTab(remainedTab ?? .home)
                self.moveBottomSheet(to: mode)
                self.navigationController?.pushViewController(self.searchVC, animated: true)
            }
        }
    }
    
    func scrollViewTracking() {
        guard let vc = currentBottomSheetVC as? BottomSheetInteractable, let scrollView = vc.trackingScrollView else { return }
        
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleScrollPan))
    }
    
    @objc
    private func handleScrollPan(_ gesture: UIPanGestureRecognizer) {
        guard let vc = currentBottomSheetVC as? BottomSheetInteractable, let scrollView = vc.trackingScrollView else { return }
        
        let velocityY = gesture.velocity(in: view).y
        let offsetY = scrollView.contentOffset.y

        switch gesture.state {

        case .changed:
            if velocityY < 0 {
                scrollView.isScrollEnabled = true
                return
            }

        case .ended, .cancelled:
            if offsetY <= 0 && velocityY >= 0 {
                scrollView.isScrollEnabled = false
                
                if mode == .max {
                    scrollView.contentOffset = .zero
                    moveBottomSheet(to: .medium)
                }
            }
        default:
            break
        }
    }
}
