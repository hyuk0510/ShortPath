//
//  Map+UI.swift
//  ShortPath
//
//  Created by 선상혁 on 12/12/25.
//

import UIKit
import KakaoMapsSDK

extension MapViewController {
    
    var currentLocationPoiView: UIView {
        let view = UIView(frame: .init(x: 20, y: 20, width: 20, height: 20))
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin_green(custom)")
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        return view
    }
    
    var currentLocationPoiBadgeView: UIView {
        let view = UIView(frame: .init(x: 5, y: 5, width: 5, height: 5))
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noti")
        imageView.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        return view
    }
    
    var placeDetailPoiView: UIView {
        let view = UIView(frame: .init(x: 0, y: 0, width: 50, height: 50))
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PlaceDetailIcon")
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
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
            
            if let image = UIImage(named: "Compass_Icon") {
                let iconRect = CGRect(x: center.x - buttonSize / 2, y: center.y - buttonSize / 2, width: buttonSize, height: buttonSize)
                
                image.withTintColor(UIColor.black.withAlphaComponent(iconAlpha), renderingMode: .alwaysOriginal).draw(in: iconRect)
            }
        }
    }
    
    func positionLogoGUI() {
        let safeAreaBottom = view.safeAreaInsets.bottom
        let safeAreaTop = view.safeAreaInsets.top
        
        spriteGui.position = CGPoint(x: 15, y: safeAreaBottom)
        kakaoMap?.setLogoPosition(origin: GuiAlignment(vAlign: .top, hAlign: .left), position: CGPoint(x: 15, y: safeAreaTop + 15))
    }
    
    func bottomSheetDidSnap(to mode: Mode, to sheetMode: SheetMode, height: CGFloat) {
        mapContainer?.transform = .identity
        guard mode != .max, !isPanned else { return }
                
        updateBottomMargin(bottomSheetHeight: height)
        
        if case .home = sheetMode {
            moveCameraToCurrentLocation()
        }
    }
    
    func updateBottomMargin(bottomSheetHeight: CGFloat) {
        kakaoMap?.setMargins(UIEdgeInsets(top: 48, left: 0, bottom: bottomSheetHeight, right: 0))
    }
    
    func resetMargin() {
        kakaoMap?.resetMargins()
        kakaoMap?.setMargins(UIEdgeInsets(top: 48, left: 0, bottom: 48, right: 0))
    }
    
    func moveToSelectedPlaceLocation(_ coordinate: (lon: Double, lat: Double)) {
        guard let kakaoMap = kakaoMap else { return }
        
        let placeLocation = MapPoint(longitude: coordinate.lon, latitude: coordinate.lat)
        
        kakaoMap.moveCamera(CameraUpdate.make(target: placeLocation, zoomLevel: 17, mapView: kakaoMap))
    }
    
    func updateGUI(bottomInset: CGFloat) {
        let safeAreaBottom = view.safeAreaInsets.bottom
        let totalInset = safeAreaBottom + bottomInset
        
        spriteGui.position = CGPoint(x: 15, y: totalInset)
    }
}
