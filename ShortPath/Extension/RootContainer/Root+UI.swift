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
        
        bottomSheetViewContainer.setShadow(-2)

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
                
        searchBarContainer.onTap = { [weak self] in
            guard let self else { return }
            
            self.navigationController?.pushViewController(makeSearchVC(mode: .main), animated: true)
        }

    }
    
    func setUpRouting() {
        [routingContainer, routeSummaryContainer, routingBottomActionContainer].forEach { view in
            self.view.addSubview(view)
        }
        
        routeSummaryContainer.addTarget(self, action: #selector(routeSummaryContainerPressed), for: .touchUpInside)
        
        routeSummaryContainer.onTapCloseButton = { [weak self] in
            guard let self else { return }
            
            self.updateSheetState(.home)
            
            if let tab = remainedTab {
                selectTab(tab)
            } else {
                setMode(.tip, animated: false)
                customTabBar.deselectAll()
            }
            
            self.mapVC.resetMargin()
            self.mapVC.removePlaceDetailPoi()
            self.mapVC.removeRoutePois()
        }
        
        routingBottomActionContainer.routingButtonPressed = { [weak self] in
            guard let self else { return }
            
            self.routingButtonPressed()
        }
        
        routingBottomActionContainer.routeToKakaoButtonPressed = { [weak self] in
            guard let self else { return }
            
            self.routeToKakaoButtonPressed()
        }
        
        routingContainer.delegate = self
        
        routingContainer.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            routingContainerHeightConstraint = make.height.equalTo(150).constraint
        }
        
        routeSummaryContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(68)
        }
        
        routingBottomActionContainer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(100)
        }
        
        routingViewModel.onChange = { [weak self] in
            guard let self else { return }
            
            self.mapVC.removeRoute()
            self.routingContainer.update(items: routingViewModel.items)
        }
        
        routingContainer.onHeightChanged = { [weak self] height in
            guard let self else { return }
            
            self.routingContainerHeightConstraint?.update(offset: height)
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func routeSummaryContainerPressed() {
        updateSheetState(.routing(.editing))
    }
    
    private func routingButtonPressed() {            
        if routingViewModel.canRouting, !routingViewModel.isSamePlaceInARow {
            self.mapVC.removePlaceDetailPoi()
            self.requestRoute()
            self.mapVC.createRoutePois(routingViewModel.items)
            self.updateSheetState(.routing(.ready))
        } else if routingViewModel.isSamePlaceInARow {
            errorAlert(title: "연속된 장소 설정", message: "루트에 연속되어 같은 장소가 설정되었는지 확인해주세요.")
        } else if !routingViewModel.canRouting {
            errorAlert(title: "루트 설정 오류", message: "출발지와 도착지를 확인해주세요.")
        }
    }
    
    private func routeToKakaoButtonPressed() {
        guard let start = routingViewModel.startPlace.place, let destination = routingViewModel.destination.place else { return }
        
        var components = URLComponents()
        components.scheme = "kakaomap"
        components.host = "route"
        
        var items: [URLQueryItem] = [
            URLQueryItem(name: "sp", value: "\(String(describing: start.latitude)),\(String(describing: start.longitude))"),
            URLQueryItem(name: "ep", value: "\(String(describing: destination.latitude)),\(String(describing: destination.longitude))"),
            URLQueryItem(name: "by", value: "foot")
        ]
        
        if let wayPoints = routingViewModel.wayPoints {
            for (index, wayPoint) in wayPoints.enumerated() {
                guard let point = wayPoint.place else { return }
                
                let name = index == 0 ? "vp" : "vp\(index + 1)"
                
                items.append(
                    URLQueryItem(name: name, value: "\(String(describing: point.latitude)),\(String(describing: point.longitude))")
                )
            }
        }
        
        components.queryItems = items
        
        guard let appURL = components.url else { return }
        
        // 카카오맵 앱 설치 여부 확인 후 앱 우선 오픈
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
            return
        }
        
        // 앱이 없으면 모바일 웹으로 폴백
        var webComponents = URLComponents()
        webComponents.scheme = "http"
        webComponents.host = "m.map.kakao.com"
        webComponents.path = "/scheme/route"
        webComponents.queryItems = items
        
        guard let webURL = webComponents.url else { return }
        UIApplication.shared.open(webURL)
    }
    
    func bindRouting() {
        routingContainer.update(items: routingViewModel.items)
        
        routingContainer.onTapSearch = { [weak self] item in
            guard let self else { return }
            
            self.pushSearchVC(item: item)
        }
        
        routingContainer.onTapAddWayPoint = { [weak self] in
            guard let self else { return }
            
            self.routingViewModel.addWayPoint()
        }
        
        routingContainer.onTapDelete = { [weak self] item in
            guard let self else { return }
            
            self.routingViewModel.removeWayPoint(id: item.id)
        }
        
        routingContainer.onMoveItem = { [weak self] (from, to) in
            guard let self else { return }
            
            self.routingViewModel.moveItem(from: from, to: to)
        }
        
        routingContainer.onTapSwap = { [weak self] in
            guard let self else { return }
            
            self.routingViewModel.swapStartDestination()
        }
    }
    
    func pushSearchVC(item: RouteSectionItem) {
        navigationController?.pushViewController(self.makeSearchVC(mode: .routing(targetID: item.id, role: item.role)), animated: false)
    }
    
    func setUpCurrentLocationButton() {
        view.addSubview(currentLocationButton)
        
        currentLocationButton.isSelected = true
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonPressed(_:)), for: .touchUpInside)
        
        updateCurrentLocationButtonLayOut()
    }
    
    @objc
    func currentLocationButtonPressed(_ sender: UIButton) {
        sender.isSelected = true
        mapVC.isPanned = false
        mapVC.moveCameraToCurrentLocation(sheetMode: rootViewModel.currentSheetMode())
    }
    
    @objc
    func didPan(_ recognizer: UIPanGestureRecognizer) {
        let translationY = recognizer.translation(in: view).y
        let newY = sheetTopConstraint.layoutConstraints.first!.constant + translationY

        let clampedY = min(
            max(Const.bottomSheetYPosition(.max, rootViewModel.currentSheetMode()), newY),
            Const.bottomSheetYPosition(.tip, rootViewModel.currentSheetMode())
        )
        
        
        switch recognizer.state {
        case .began:
            dragStartTop = sheetTopConstraint.layoutConstraints.first?.constant ?? CGFloat(Const.bottomSheetYPosition(mode, rootViewModel.currentSheetMode()))

        case .changed:
            sheetTopConstraint.update(offset: clampedY)
            view.layoutIfNeeded()
            
            let bottomSheetheight = view.bounds.height - clampedY
            
            (currentBottomSheetVC as? BottomSheetStateApplicable)?.buttonEnabled = false

            if case .home = rootViewModel.currentSheetMode() {
                if mode != .max, !mapVC.isPanned {
                    mapVC.updateBottomMargin(bottomSheetHeight: bottomSheetheight)
                    mapVC.moveCameraToCurrentLocation()
                }
            }
                        
            recognizer.setTranslation(.zero, in: view)
            
        case .ended, .cancelled:
            let targetMode: Mode = nearestMode(startTop: dragStartTop, currentTop: clampedY, currentMode: mode, containerHeight: view.bounds.height)
                        
            mapVC.bottomSheetDidSnap(to: targetMode, to: rootViewModel.currentSheetMode(), height: view.bounds.height - Const.bottomSheetYPosition(targetMode, rootViewModel.currentSheetMode()))
            
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
        remainedTab = tab
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
    
    func moveBottomSheet(to targetMode: Mode, animated: Bool = true) {
        let targetTop = Const.bottomSheetYPosition(targetMode, rootViewModel.currentSheetMode())
        
        let bototmSheetMove = {
            self.sheetTopConstraint.update(offset: targetTop)
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.4,
                options: [.allowUserInteraction, .curveEaseOut]
            ) {
                bototmSheetMove()
            }
        } else {
            bototmSheetMove()
        }
        
        (currentBottomSheetVC as? BottomSheetStateApplicable)?.changedBottomSheetState(targetMode)
        
        DispatchQueue.main.async { [weak self] in
            (self?.currentBottomSheetVC as? BottomSheetStateApplicable)?.buttonEnabled = true
        }
    }
    
    func setMode(_ newMode: Mode, animated: Bool = true) {
        mode = newMode

        updateOverlay(mode: mode, sheetMode: rootViewModel.currentSheetMode())
        view.layoutIfNeeded()
        
        updateScrollPermission(for: mode)
        
        if newMode == .tip {
            customTabBar.deselectAll()
            remainedTab = nil
        }
        
        moveBottomSheet(to: newMode, animated: animated)
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
        switch newMode {
        case .home:
            rootViewModel.backToHome()
            
            if let tab = remainedTab {
                selectTab(tab)
                setMode(mode)
            } else {
                setMode(.tip, animated: false)
                customTabBar.deselectAll()
            }
            
        case .placeDetail(let place):
            rootViewModel.selectedPlace(place)
            setMode(mode)
            
        case .routing(let routingMode):
            mapVC.positionLogo(128)
            rootViewModel.routingMode(routingMode)
        }
        
        updateCurrentLocationButtonLayOut()
        render()
    }
    
    func render() {
        switch rootViewModel.currentSheetMode() {
        case .home:
            customTabBar.isHidden = false
            searchBarContainer.isHidden = false
            bottomSheetViewContainer.isHidden = false
            hideRouting()
            
            searchBarContainer.configureHome()
            
        case .placeDetail(let place):
            customTabBar.isHidden = true
            searchBarContainer.isHidden = false
            bottomSheetViewContainer.isHidden = false
            hideRouting()
            
            searchBarContainer.configurePlaceDetail(place)
            
            searchBarContainer.onTap = { [weak self] in
                guard let self = self else { return }

                self.updateSheetState(.home)
                self.navigationController?.pushViewController(makeSearchVC(mode: .main), animated: false)
                
            }
            
        case .routing(let routingMode):
            bottomSheetViewContainer.isHidden = true
            customTabBar.isHidden = true
            searchBarContainer.isHidden = true
            
            showRouting(routingMode)
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
                    max(Const.bottomSheetYPosition(.max, rootViewModel.currentSheetMode()), newTop),
                    Const.bottomSheetYPosition(.tip, rootViewModel.currentSheetMode())
                )
                
                sheetTopConstraint.update(offset: clampedTop)
                view.layoutIfNeeded()
            } else {
                isScrollDragged = false
            }
            
        case .ended, .cancelled:
            guard isScrollDragged else { return }

            let currentTop = sheetTopConstraint.layoutConstraints.first?.constant ?? CGFloat(Const.bottomSheetYPosition(mode, rootViewModel.currentSheetMode()))
            let target = nearestMode(startTop: scrollViewSheetStartTop, currentTop: currentTop, currentMode: .max, containerHeight: view.bounds.height)
            
            scrollView.setContentOffset(.zero, animated: false)
            setMode(target)
            
            isScrollDragged = false
            gesture.setTranslation(.zero, in: view)
            
        default:
            break
        }
    }
    
    func updateCurrentLocationButtonLayOut(animated: Bool = false) {
        currentLocationButton.snp.remakeConstraints { make in
            switch rootViewModel.currentSheetMode() {
            case .home, .placeDetail(_):
                make.bottom.equalTo(bottomSheetViewContainer.snp.top).offset(-16)
            case .routing(let routingMode):
                if routingMode == .none {
                    make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
                } else {
                    make.bottom.equalTo(routingBottomActionContainer.snp.top).offset(-16)
                    
                }
            }
            
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.width.height.equalTo(48)
        }
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }
    
    func currentLocationButtonState(mode: Mode, sheetMode: SheetMode) -> Bool {
        switch sheetMode {
        case .home, .placeDetail:
            return mode != .max
        case .routing:
            return true
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
    
    func showPlaceDetail(place: Place, vc: UIViewController, coordinate: (Double, Double)) {
        mapVC.isPanned = true
        currentLocationButton.isSelected = false

        updateSheetState(.placeDetail(place))
        
        switchBottomSheet(vc)
        setMode(.medium, animated: true)
                
        mapVC.createPlaceDetailPoi(coordinate: coordinate, placeName: place.name)
        mapVC.moveToSelectedPlaceLocation(coordinate, sheetMode: rootViewModel.currentSheetMode())
    }
    
    func makeSearchVC(mode: SearchMode) -> SearchViewController {
        let vc = SearchViewController(mode: mode)
        vc.coordinate = mapVC.currentLocation
        vc.delegate = self
        return vc
    }
    
    func showRouting(_ routingMode: RoutingMode) {
        switch routingMode {
        case .none:
            routeSummaryContainer.bind(start: routingViewModel.startPlace.place?.name, destination: routingViewModel.destination.place?.name, wayPointsCount: routingViewModel.numberOfItems - 2)
            routingContainer.isHidden = true
            routeSummaryContainer.isHidden = false
            routingBottomActionContainer.isHidden = true
        case .editing:
            bindRouting()
            routingContainer.isHidden = false
            routeSummaryContainer.isHidden = true
            routingBottomActionContainer.isHidden = false
            routingBottomActionContainer.setByMode(routingMode)
        case .ready:
            routeSummaryContainer.bind(start: routingViewModel.startPlace.place?.name, destination: routingViewModel.destination.place?.name, wayPointsCount: routingViewModel.numberOfItems - 2)
            routingContainer.isHidden = true
            routeSummaryContainer.isHidden = false
            routingBottomActionContainer.isHidden = false
            routingBottomActionContainer.setByMode(routingMode)
        }
    }
    
    func hideRouting() {
        routingViewModel.resetItems()
        routingContainer.isHidden = true
        routeSummaryContainer.isHidden = true
        routingBottomActionContainer.isHidden = true
    }
    
    func requestRoute() {
        routeTask?.cancel()
        
        routeTask = Task {
            do {
                let route = try await KakaoLocalManager.shared.fetchRoute(routingViewModel.items)
             
                await MainActor.run {
                    self.mapVC.moveToRoute(route.routes[0].summary.bound)
                    self.mapVC.createRouteLine(route.routes[0].sections)
                }
            } catch {
                print(error)
            }
        }
        
    }
}
