//
//  RoutingButton.swift
//  ShortPath
//
//  Created by 선상혁 on 3/28/26.
//

import UIKit

final class RoutingButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
        setShadow()
        
        var config = UIButton.Configuration.filled()
        var titleContainer = AttributeContainer()
        
        titleContainer.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        config.attributedTitle = AttributedString("경로 보기", attributes: titleContainer)
        config.titleAlignment = .center
        config.baseForegroundColor = .white
        
        configuration = config
    }
    
}
