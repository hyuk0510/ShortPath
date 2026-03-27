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
        let view = UIView(frame: .init(x: 0, y: 0, width: 20, height: 20))

        let imageView = UIImageView()
        imageView.image = UIImage(named: "CurrentLocation")
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        return view
    }
    
    var placeDetailPoiView: UIView {
        let view = UIView(frame: .init(x: 0, y: 0, width: 36, height: 36))
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PlacePin")
        imageView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        return view
    }
    
    var startPlacePoiView: UIView {
        let view = UIView(frame: .init(x: 0, y: 0, width: 36, height: 36))
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StartPlace")
        imageView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        return view
    }
    
    var wayPointsPoiView: [UIView] {
        var viewArr: [UIView] = []
        
        for i in 1...5 {
            let view = UIView(frame: .init(x: 0, y: 0, width: 36, height: 36))
            let imageView = UIImageView()
            imageView.image = UIImage(named: "WayPoint_\(i)")
            imageView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
            imageView.contentMode = .scaleAspectFit
            
            view.addSubview(imageView)
            viewArr.append(view)
        }
        
        return viewArr
    }
    
    var destinationPlacePoiView: UIView {
        let view = UIView(frame: .init(x: 0, y: 0, width: 36, height: 36))
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Destination")
        imageView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        return view
    }
    
    func positionLogo() {
        let safeAreaTop = view.safeAreaInsets.top
        
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
    
    func moveToSelectedPlaceLocation(_ coordinate: (lon: Double, lat: Double), sheetMode: SheetMode) {
        guard let kakaoMap = kakaoMap else { return }
        
        switch sheetMode {
        case .home:
            return
        case .placeDetail(_):
            let targetPosition = kakaoMap.getPosition(CGPoint(x: UIScreen.main.bounds.width * 0.5, y: (UIScreen.main.bounds.height * 0.5 + 48) * 0.5))
            let distance = CameraTransformDelta(deltaLon: coordinate.lon - targetPosition.wgsCoord.longitude, deltaLat: coordinate.lat - targetPosition.wgsCoord.latitude)
            let cameraTransForm = CameraUpdate.make(transform: CameraTransform(deltaPos: distance, deltaHeight: 0, deltaRotation: 0, deltaTilt: 0))
            
            kakaoMap.moveCamera(cameraTransForm)

        case .routing:
            let targetPosition = MapPoint(longitude: coordinate.lon, latitude: coordinate.lat)
            let cameraUpdate = CameraUpdate.make(target: targetPosition, zoomLevel: 17, mapView: kakaoMap)
            
            kakaoMap.moveCamera(cameraUpdate)
        }
        
    }
    
    func moveToRoute(_ bound: Bound) {
        guard let kakaoMap = kakaoMap else { return }
        
        let southWestPoint = MapPoint(longitude: bound.minX, latitude: bound.minY)
        let northEastPoint = MapPoint(longitude: bound.maxX, latitude: bound.maxY)
        
        let cameraUpdate = CameraUpdate.make(area: AreaRect(southWest: southWestPoint, northEast: northEastPoint))
        
        kakaoMap.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: true, consecutive: true, durationInMillis: 2000))
    }
}
