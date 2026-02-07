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
    
    func setKaKaoLogo() {
        kakaoMap?.setLogoPosition(origin: GuiAlignment(vAlign: .top, hAlign: .left), position: CGPoint(x: 30, y: 150))
    }
    
    func applyVisualOffset(offset: CGFloat) {
        mapContainer?.transform = CGAffineTransform(translationX: 0, y: -offset)
    }
    
    func bottomSheetDidSnap(to mode: Mode, height: CGFloat) {
        mapContainer?.transform = .identity
        guard mode != .max, !isPanned else { return }
                
//        snapCameraToVisibleCenter(bottomSheetHeight: height)
        updateBottomMargin(bottomSheetHeight: height)
        moveCameraToCurrentLocation()
    }
    
    func snapCameraToVisibleCenter(bottomSheetHeight: CGFloat) {
        guard let location = currentLocation, let kakaoMap = kakaoMap else { return }
                        
        let centerY = bottomSheetHeight / 2
        
        if let _ = targetMapPoint {
        
        } else {
            targetMapPoint = kakaoMap.getPosition(CGPoint(x: view.bounds.midX, y: view.bounds.midY + centerY))
        }
        
        let targetLon = targetMapPoint?.wgsCoord.longitude ?? location.coordinate.longitude
        let targetLat = targetMapPoint?.wgsCoord.latitude ?? location.coordinate.latitude
        
        kakaoMap.moveCamera(CameraUpdate.make(cameraPosition: CameraPosition(target: MapPoint(longitude: targetLon, latitude: targetLat), zoomLevel: 17, rotation: 0, tilt: 0)))
    }
//    
//    func tryApplyInitialCameraIfPossible() {
//        guard hasInitialLocation, isMapReady, let _ = currentLocation else { return }
//        
//        initialLocationDelegate?.mapViewControllerDidReceivedInitialLocation(self)
//        
//        hasInitialLocation = true
//    }
    
    func updateBottomMargin(bottomSheetHeight: CGFloat) {
        kakaoMap?.setMargins(UIEdgeInsets(top: 0, left: 0, bottom: bottomSheetHeight, right: 0))
    }
    
    func resetMargin() {
        kakaoMap?.resetMargins()
    }
}
