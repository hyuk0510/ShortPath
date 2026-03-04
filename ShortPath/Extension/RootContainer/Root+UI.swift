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
        let newY = sheetTopConstraint.layoutConstraints.first!.constant + translationY

        let clampedY = min(
            max(Const.bottomSheetYPosition(.max, viewModel.sheetMode), newY),
            Const.bottomSheetYPosition(.tip, viewModel.sheetMode)
        )
        
        
        switch recognizer.state {
        case .began:
            dragStartTop = sheetTopConstraint.layoutConstraints.first?.constant ?? CGFloat(Const.bottomSheetYPosition(mode, viewModel.sheetMode))
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
            let targetMode: Mode = nearestMode(startTop: dragStartTop, currentTop: clampedY, currentMode: mode, containerHeight: view.bounds.height)
            
            mapVC.bottomSheetDidSnap(to: targetMode, to: viewModel.sheetMode, height: view.bounds.height - Const.bottomSheetYPosition(targetMode, viewModel.sheetMode))
            
            if targetMode == .max {
                if !mapVC.isPanned {
                    mapVC.resetMargin()
                    mapVC.moveCameraToCurrentLocation()
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
        updateScrollPermission(for: mode)
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
        mode = newMode

        updateOverlay(mode: mode, sheetMode: viewModel.sheetMode)
        view.layoutIfNeeded()
        
        updateScrollPermission(for: mode)
        
        
        if newMode == .tip {
            customTabBar.deselectAll()
        }
        
        moveBottomSheet(to: newMode)
    }
    
    private func nearestMode(
        startTop: CGFloat,
        currentTop: CGFloat,
        currentMode: Mode,
        containerHeight: CGFloat
    ) -> Mode {
        
        let delta = currentTop - startTop
        
        let oneStepDist = containerHeight * 0.06
        let twoStepDist = containerHeight * 0.18
        
        if delta >= twoStepDist {
            switch currentMode {
            case .max:    return .tip
            case .medium: return .tip
            case .tip:    return .tip
            }
        }
        
        if delta >= oneStepDist {
            switch currentMode {
            case .max:    return .medium
            case .medium: return .tip
            case .tip:    return .tip
            }
        }
        
        if delta <= -twoStepDist {
            switch currentMode {
            case .tip:    return .max
            case .medium: return .max
            case .max:    return .max
            }
        }
        
        if delta <= -oneStepDist {
            switch currentMode {
            case .tip:    return .medium
            case .medium: return .max
            case .max:    return .max
            }
        }
        
        return currentMode
    }
    
    func updateSheetState(_ newMode: SheetMode) {
        viewModel.sheetMode = newMode
        setMode(mode)
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
                self.navigationController?.pushViewController(self.searchVC, animated: true)
            }
        }
    }
    
    func scrollViewTracking() {
        if let prev = trackedScrollView {
            prev.panGestureRecognizer.removeTarget(self, action: #selector(handleScrollPan))
        }
        
        guard let vc = currentBottomSheetVC as? BottomSheetInteractable, let scrollView = vc.trackingScrollView else { return }
        
        trackedScrollView = scrollView
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleScrollPan))
    }
    
    @objc
    private func handleScrollPan(_ gesture: UIPanGestureRecognizer) {
        guard mode == .max, let scrollView = trackedScrollView else { return }
        
        let velocityY = gesture.velocity(in: view).y
        let offsetY = scrollView.contentOffset.y
        let translationy = gesture.translation(in: view).y

        switch gesture.state {
        case .began:
            scrollViewSheetStartTop = sheetTopConstraint.layoutConstraints.first?.constant ?? 0
            isScrollDragged = false
        case .changed:
            if offsetY <= 0, velocityY > 0 {
                isScrollDragged = true
                
                if scrollView.contentOffset.y != 0 {
                    scrollView.contentOffset = .zero
                }
                
                let newTop = scrollViewSheetStartTop + translationy
                let clampedTop = min(
                    max(Const.bottomSheetYPosition(.max, viewModel.sheetMode), newTop),
                    Const.bottomSheetYPosition(.tip, viewModel.sheetMode)
                )
                
                sheetTopConstraint.update(offset: clampedTop)
                view.layoutIfNeeded()
            } else {
                isScrollDragged = false
            }
        case .ended, .cancelled:
            guard isScrollDragged else { return }

            let currentTop = sheetTopConstraint.layoutConstraints.first?.constant ?? CGFloat(Const.bottomSheetYPosition(mode, viewModel.sheetMode))
            let target = nearestMode(startTop: scrollViewSheetStartTop, currentTop: currentTop, currentMode: .max, containerHeight: view.bounds.height)
            
            scrollView.setContentOffset(.zero, animated: false)
            setMode(target)
            
            isScrollDragged = false
            gesture.setTranslation(.zero, in: view)
            
        default:
            break
        }
    }
    
    func currentLocationButtonState(mode: Mode, sheetMode: SheetMode) -> Bool {
        switch sheetMode {
        case .home, .placeDetail:
            return mode != .max
        }
    }
    
    func updateOverlay(mode: Mode, sheetMode: SheetMode) {
        let state = currentLocationButtonState(mode: mode, sheetMode: sheetMode)
        currentLocationButton.isHidden = !state
        
        if state {
            view.bringSubviewToFront(currentLocationButton)
        }
    }
    
    func updateScrollPermission(for mode: Mode) {
        guard let vc = currentBottomSheetVC as? BottomSheetInteractable, let scrollView = vc.trackingScrollView else { return }
        
        let enabled = (mode == .max)
        
        scrollView.isScrollEnabled = enabled
        
        if !enabled {
            scrollView.setContentOffset(.zero, animated: false)
        }
    }
    
    func showPlaceDetail(place: Document, vc: UIViewController, coordinate: (Double, Double)) {
        mapVC.isPanned = true

        updateSheetState(.placeDetail(place))
        
        switchBottomSheet(vc)
        
        setMode(.medium, animated: true)
        
        mapVC.createPlaceDetailPoi(coordinate: coordinate)
        mapVC.moveToSelectedPlaceLocation(coordinate)
    }
}
