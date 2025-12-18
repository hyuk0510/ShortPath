//
//  Map+UI.swift
//  ShortPath
//
//  Created by 선상혁 on 12/12/25.
//

import UIKit
import KakaoMapsSDK

extension MapViewController {
    
    var poiView: UIView {
        let view = UIView(frame: .init(x: 20, y: 20, width: 20, height: 20))
        view.backgroundColor = .green
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin_green")
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        return view
    }
    
    var poiBadgeView: UIView {
        let view = UIView(frame: .init(x: 5, y: 5, width: 5, height: 5))
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noti")
        imageView.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        return view
    }
    
    func makeCirculaerButtonImage(
        buttonSize: CGFloat = 25,
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
            
            if let image = UIImage(systemName: "arrow.clockwise.circle") {
                let iconRect = CGRect(x: center.x - 7.5, y: center.y - 7.5, width: 15, height: 15)
                
                image.withTintColor(UIColor.black.withAlphaComponent(iconAlpha), renderingMode: .alwaysOriginal).draw(in: iconRect)
            }
        }
    }
    
    func setKakaoMapLogo() {
        kakaoMap.setLogoPosition(origin: GuiAlignment(vAlign: .bottom, hAlign: .left), position: CGPoint(x: 30, y: 30))
    }
}
