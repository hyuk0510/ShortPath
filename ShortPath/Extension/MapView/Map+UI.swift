//
//  Map+UI.swift
//  ShortPath
//
//  Created by 선상혁 on 12/12/25.
//

import UIKit
import KakaoMapsSDK

extension MapViewController {

    private func makePoiImageView(imageName: String, size: CGFloat, shadow: Bool = true, animated: Bool = true) -> UIView {
        let view = UIView(frame: .init(x: 0, y: 0, width: size, height: size))
        view.backgroundColor = .clear

        if shadow {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.16
            view.layer.shadowRadius = 4
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.masksToBounds = false
        }

        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: size, height: size))
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit

        view.addSubview(imageView)

        if animated {
            view.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
            view.alpha = 0
            UIView.animate(
                withDuration: 0.24,
                delay: 0,
                usingSpringWithDamping: 0.72,
                initialSpringVelocity: 0.65,
                options: [.curveEaseOut, .allowUserInteraction]
            ) {
                view.transform = .identity
                view.alpha = 1
            }
        }

        return view
    }

    var currentLocationPoiView: UIView {
        makePoiImageView(imageName: "CurrentLocationDirection", size: 24, shadow: false, animated: false)
    }

    var placeDetailPoiView: UIView {
        makePoiImageView(imageName: "PlacePin", size: 36, shadow: true, animated: true)
    }

    var startPlacePoiView: UIView {
        makePoiImageView(imageName: "StartPlace_Glass", size: 32, shadow: true, animated: true)
    }

    var wayPointsPoiView: [UIView] {
        var viewArr: [UIView] = []

        for i in 1...5 {
            let view = makePoiImageView(imageName: "WayPoint_\(i)_Glass", size: 32, shadow: true, animated: true)
            viewArr.append(view)
        }

        return viewArr
    }

    var destinationPlacePoiView: UIView {
        makePoiImageView(imageName: "Destination_Glass", size: 34, shadow: true, animated: true)
    }

    var favoritePoiView: UIView {
        makePoiImageView(imageName: "FavoritePoiImage", size: 16, shadow: true, animated: true)
    }
    
    func positionLogo(_ safeAreaTop: CGFloat) {
        guard let kakaoMap = kakaoMap else { return }
        
        let margins = kakaoMap.margins
        let position = CGPoint(x: 16 - margins.left, y: safeAreaTop + 16 - margins.top)
        
        kakaoMap.setLogoPosition(origin: GuiAlignment(vAlign: .top, hAlign: .left), position: position)
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
        guard let kakaoMap = kakaoMap else { return }

        kakaoMap.setMargins(UIEdgeInsets(top: 0, left: 0, bottom: bottomSheetHeight, right: 0))
    }
    
    func resetMargin() {
        guard let kakaoMap = kakaoMap else { return }

        kakaoMap.resetMargins()
        kakaoMap.setMargins(UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0))
        positionLogo(96)
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
    
    func moveToRoute(_ bound: RouteBounds) {
        guard let kakaoMap = kakaoMap else { return }
        
        let southWestPoint = MapPoint(longitude: bound.minLng, latitude: bound.minLat)
        let northEastPoint = MapPoint(longitude: bound.maxLng, latitude: bound.maxLat)
        
        let cameraUpdate = CameraUpdate.make(area: AreaRect(southWest: southWestPoint, northEast: northEastPoint))
        
        kakaoMap.setMargins(UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))
        positionLogo(128)
        kakaoMap.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: true, consecutive: true, durationInMillis: 500))
    }
}
