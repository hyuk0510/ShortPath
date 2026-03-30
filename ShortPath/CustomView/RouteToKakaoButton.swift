//
//  RouteToKakaoButton.swift
//  ShortPath
//
//  Created by 선상혁 on 3/28/26.
//

import UIKit

final class RouteToKakaoButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        var config = UIButton.Configuration.filled()
        var container = AttributeContainer()
        
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        config.attributedTitle = AttributedString("카카오맵에서 도보 경로 보기", attributes: container)
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        
        configuration = config
    }
}
