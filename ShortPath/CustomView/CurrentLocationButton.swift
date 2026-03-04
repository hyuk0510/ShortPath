//
//  CurrentLocationButton.swift
//  ShortPath
//
//  Created by 선상혁 on 3/4/26.
//

import UIKit

final class CurrentLocationButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let normalImage = makeCirculaerButtonImage(iconAlpha: 0.2)
        let selectedImage = makeCirculaerButtonImage(iconAlpha: 1.0)
        
        backgroundColor = .clear
        setImage(normalImage, for: .normal)
        setImage(selectedImage, for: .selected)
        layer.cornerRadius = 15
        layer.masksToBounds = true
        setShadow()
    }
    
    func makeCirculaerButtonImage(
        buttonSize: CGFloat = 48,
        shadowRadius: CGFloat = 3,
        shadowOffset: CGSize = CGSize(width: 0, height: 1),
        iconAlpha: CGFloat
    ) -> UIImage {
        
        let padding = shadowRadius + abs(shadowOffset.height)
        let size = buttonSize + padding * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        
        return renderer.image { ctx in
            let context = ctx.cgContext
            context.setAllowsAntialiasing(true)
            context.setShouldAntialias(true)
            
            let center = CGPoint(x: size / 2, y: size / 2)
            let circleRect = CGRect(x: center.x - buttonSize / 2, y: center.y - buttonSize / 2, width: buttonSize, height: buttonSize)
            
            context.setShadow(offset: shadowOffset, blur: shadowRadius, color: UIColor.black.withAlphaComponent(0.3).cgColor)
            
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: circleRect)
            
            context.setShadow(offset: .zero, blur: 0)
            
            if let image = UIImage(named: "Compass_Icon") {
                let iconRect = CGRect(x: center.x - buttonSize / 2, y: center.y - buttonSize / 2, width: buttonSize, height: buttonSize)
                
                image.withTintColor(UIColor.black.withAlphaComponent(iconAlpha), renderingMode: .alwaysOriginal).draw(in: iconRect)
            }
        }
    }
}
