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
    
    func positionLogoGUI() {
        let safeAreaBottom = view.safeAreaInsets.bottom
        let safeAreaTop = view.safeAreaInsets.top
        
        spriteGui.position = CGPoint(x: 15, y: safeAreaBottom)
        kakaoMap?.setLogoPosition(origin: GuiAlignment(vAlign: .top, hAlign: .left), position: CGPoint(x: 15, y: safeAreaTop + 15))
    }
    
//    func applyVisualOffset(offset: CGFloat) {
//        mapContainer?.transform = CGAffineTransform(translationX: 0, y: -offset)
//    }
//    
//    func applyCameraOffset(bottomSheetHeight: CGFloat) {
//        guard let kakaoMap = kakaoMap else { return }
//        guard let currentLocation = currentLocation else { return }
//        
//        let visibleHeight = mapContainer!.bounds.height - bottomSheetHeight
//        let visibleCenterY = visibleHeight / 2
//        let screenCenterY = mapContainer!.bounds.midY
//        let offset = screenCenterY - visibleCenterY
//        let targetScreenPoint = CGPoint(x: mapContainer!.bounds.midX, y: visibleHeight / 2)
//        print(offset)
//        
//        let targetMapPoint = kakaoMap.getPosition(targetScreenPoint)
//        let centerMapPoint = kakaoMap.getPosition(CGPoint(x: mapContainer!.bounds.midX, y: mapContainer!.bounds.midY))
//        
//        let latDelta = centerMapPoint.wgsCoord.latitude - targetMapPoint.wgsCoord.latitude
//        let lngDelta = centerMapPoint.wgsCoord.longitude - targetMapPoint.wgsCoord.longitude
//        
//        print(latDelta, lngDelta)
//        
//        let adjustedCenter = MapPoint(longitude: currentLocation.coordinate.longitude + lngDelta, latitude: currentLocation.coordinate.latitude + latDelta)
//                
//        kakaoMap.moveCamera(CameraUpdate.make(target: adjustedCenter, mapView: kakaoMap))
//    }
    
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
