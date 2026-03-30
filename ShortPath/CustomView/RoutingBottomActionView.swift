//
//  RoutingBottomActionView.swift
//  ShortPath
//
//  Created by 선상혁 on 3/28/26.
//

import UIKit

final class RoutingBottomActionView: UIView {
    
    let routeButton = RoutingButton()
    let walkingRouteTokakaoButton = RouteToKakaoButton()
    
    var routingButtonPressed: (() -> Void)?
    var routeToKakaoButtonPressed: (() -> Void)?
    
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
        
        [routeButton, walkingRouteTokakaoButton].forEach { view in
            addSubview(view)
        }
        
        routeButton.isEnabled = false
        walkingRouteTokakaoButton.isEnabled = false
        
        routeButton.addTarget(self, action: #selector(routeButtonPressed), for: .touchUpInside)
        walkingRouteTokakaoButton.addTarget(self, action: #selector(walkingRouteTokakaoButtonPressed), for: .touchUpInside)
        
        routeButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        
        walkingRouteTokakaoButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
    }
    
    @objc
    private func routeButtonPressed() {
        routingButtonPressed?()
    }
    
    @objc
    private func walkingRouteTokakaoButtonPressed() {
        routeToKakaoButtonPressed?()
    }
    
    func setByMode(_ routingMode: RoutingMode) {
        switch routingMode {
        case .none:
            routeButton.isHidden = true
            walkingRouteTokakaoButton.isHidden = true
        case .editing:
            routeButton.isEnabled = true
            routeButton.isHidden = false
            walkingRouteTokakaoButton.isHidden = true
            walkingRouteTokakaoButton.isEnabled = false
        case .ready:
            routeButton.isHidden = true
            routeButton.isEnabled = false
            walkingRouteTokakaoButton.isEnabled = true
            walkingRouteTokakaoButton.isHidden = false
        }
    }
}
