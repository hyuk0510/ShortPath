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
            
    private let mapOverlayView = UIView()
    
    private var currentBottomSheetVC: UIViewController?
        
    private var sheetTopConstraint: Constraint!
        
    private(set) var mode: Mode = .medium
    
    var testView: UIView {
        let view = UIView()
        view.backgroundColor = .red
        view.frame = CGRect(x: 30, y: 300, width: 20, height: 20)
        return view
    }
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMap()
//        setUpOverlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        setUpBottomSheet()
        setUpTabBar()
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
        let height: CGFloat = 60 + view.safeAreaInsets.bottom
        
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
    
//    private func setUpOverlay() {
//        mapOverlayView.isUserInteractionEnabled = false
//        mapOverlayView.backgroundColor = .clear
//        
//        view.addSubview(mapOverlayView)
//        view.bringSubviewToFront(mapOverlayView)
//        
//        mapOverlayView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        
//        mapOverlayView.addSubview(testView)
//    }
    
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
            let targetMode: Mode = resolveTargetMode(currentMode: mode, velocityY: velocityY, currentTop: clampedY)
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
        velocityY: CGFloat
    ) -> Mode {
        
        // 빠르게 튕기면 방향 우선
        if abs(velocityY) > 700 {
            return velocityY > 0 ? .tip : .max
        }
        
        let candidates: [(Mode, CGFloat)] = [
            (.max, abs(currentTop - Const.bottomSheetYPosition(.max))),
            (.medium, abs(currentTop - Const.bottomSheetYPosition(.medium))),
            (.tip, abs(currentTop - Const.bottomSheetYPosition(.tip)))
        ]
        
        return candidates.min(by: { $0.1 < $1.1 })!.0
    }
    
    private func resolveTargetMode(
        currentMode: Mode,
        velocityY: CGFloat,
        currentTop: CGFloat
    ) -> Mode {
        
        // 🔴 max 상태에서 아래로 드래그 → 무조건 medium
        if currentMode == .max, velocityY > 0 {
            return .medium
        }
        
        // 🔴 max 상태에서 위로 드래그 → 그대로 max
        if currentMode == .max, velocityY <= 0 {
            return .max
        }
        
        // 🔵 그 외 상태에서는 기존 스냅 규칙 사용
        return nearestMode(
            currentTop: currentTop,
            velocityY: velocityY
        )
    }
}
