//
//  RouteStartButton.swift
//  ShortPath
//
//  Created by 선상혁 on 4/13/26.
//

import UIKit

final class RouteStartButton: UIButton {
    
    var onTapRouteStart: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        var configuration = UIButton.Configuration.filled()
        
        configuration.image = UIImage(named: "RouteStartButton")
        configuration.baseBackgroundColor = UIColor(hex: "0x3B82F6")
        
        self.configuration = configuration
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addTarget(self, action: #selector(routeStartButtonPressed), for: .touchUpInside)
    }
    
    @objc
    private func routeStartButtonPressed() {
        onTapRouteStart?()
    }
}
