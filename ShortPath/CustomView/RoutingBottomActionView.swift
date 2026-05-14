//
//  RoutingBottomActionView.swift
//  ShortPath
//
//  Created by 선상혁 on 3/28/26.
//

import UIKit

final class RoutingBottomActionView: UIView {
    
    let routeButton = RoutingButton()
    let walkingRouteButton = WalkingRouteButton()
    
    var routingButtonPressed: (() -> Void)?
    var walkingRouteButtonPressed: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        isHidden = true
        setShadow()
        
        [routeButton, walkingRouteButton].forEach { view in
            addSubview(view)
        }
        
        routeButton.isEnabled = false
        walkingRouteButton.isEnabled = false
        
        routeButton.addTarget(self, action: #selector(routeButtonPressed), for: .touchUpInside)
        walkingRouteButton.addTarget(self, action: #selector(walkingRouteButtonTapped), for: .touchUpInside)
        
        routeButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        
        
        walkingRouteButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            make.height.equalTo(44)
        }
    }
    
    @objc
    private func routeButtonPressed() {
        routingButtonPressed?()
    }
    
    @objc
    private func walkingRouteButtonTapped() {
        walkingRouteButtonPressed?()
    }
    
    func setByMode(_ routingMode: RoutingMode) {
        switch routingMode {
        case .none:
            routeButton.isHidden = true
            walkingRouteButton.isHidden = true
        case .editing:
            routeButton.isEnabled = true
            routeButton.isHidden = false
            walkingRouteButton.isHidden = true
            walkingRouteButton.isEnabled = false
        case .ready:
            routeButton.isHidden = true
            routeButton.isEnabled = false
            walkingRouteButton.isEnabled = true
            walkingRouteButton.isHidden = false
        }
    }
}
