//
//  Map+Poi.swift
//  ShortPath
//
//  Created by 선상혁 on 12/12/25.
//

import UIKit
import KakaoMapsSDK
import CoreLocation

extension MapViewController {
    
    func createLabelLayer() {
        guard let kakaoMap = kakaoMap else { return }
        let manager = kakaoMap.getLabelManager()
        
        let currentLocationLayerOption = LabelLayerOptions(layerID: "CurrentLocationPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10001)
        let placeDetailLayerOption = LabelLayerOptions(layerID: "PlaceDetailPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10000)
        let routesLayerOption = LabelLayerOptions(layerID: "RoutePoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 9999)
        
        let _ = manager.addLabelLayer(option: currentLocationLayerOption)
        let _ = manager.addLabelLayer(option: placeDetailLayerOption)
        let _ = manager.addLabelLayer(option: routesLayerOption)
    }
    
    func createPoiStyle() {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getLabelManager()
        
        // 현재 위치 Poi
        let currentLocationImage = UIImage(named: "CurrentLocation")
        let currentLocationIconStyle = PoiIconStyle(symbol: currentLocationImage, anchorPoint: CGPoint(x: 0.5, y: 0.5))
        let perLevelCurrentLocationStyle = PerLevelPoiStyle(iconStyle: currentLocationIconStyle, level: 0)
        let currentLocationStyle = PoiStyle(styleID: "CurrentLocationStyle", styles: [perLevelCurrentLocationStyle])
        
        manager.addPoiStyle(currentLocationStyle)
        
        // 장소 위치 Poi
        let placeDetailIconStyle = PoiIconStyle(symbol: placeDetailPoiView.asImage(), anchorPoint: CGPoint(x: 0.5, y: 1))
        let perLevelPlaceDetailStyle = PerLevelPoiStyle(iconStyle: placeDetailIconStyle)
        let placeDetailStyle = PoiStyle(styleID: "PlaceDetailStyle", styles: [perLevelPlaceDetailStyle])
        
        manager.addPoiStyle(placeDetailStyle)
        
        // 루트 각 장소 Poi
        
        // 출발지
        let startPlacePoiIconStyle = PoiIconStyle(symbol: startPlacePoiView.asImage(), anchorPoint: CGPoint(x: 0.5, y: 1))
        let startPlacePoiStyle = PerLevelPoiStyle(iconStyle: startPlacePoiIconStyle)
        
        // 경유지
        let wayPoint1PoiIconStyle = PoiIconStyle(symbol: wayPointsPoiView[0].asImage(), anchorPoint: CGPoint(x: 0.5, y: 1))
        let wayPoint1PoiStyle = PerLevelPoiStyle(iconStyle: wayPoint1PoiIconStyle)
        
        let wayPoint2PoiIconStyle = PoiIconStyle(symbol: wayPointsPoiView[1].asImage(), anchorPoint: CGPoint(x: 0.5, y: 1))
        let wayPoint2PoiStyle = PerLevelPoiStyle(iconStyle: wayPoint2PoiIconStyle)
        
        let wayPoint3PoiIconStyle = PoiIconStyle(symbol: wayPointsPoiView[2].asImage(), anchorPoint: CGPoint(x: 0.5, y: 1))
        let wayPoint3PoiStyle = PerLevelPoiStyle(iconStyle: wayPoint3PoiIconStyle)
        
        let wayPoint4PoiIconStyle = PoiIconStyle(symbol: wayPointsPoiView[3].asImage(), anchorPoint: CGPoint(x: 0.5, y: 1))
        let wayPoint4PoiStyle = PerLevelPoiStyle(iconStyle: wayPoint4PoiIconStyle)
        
        let wayPoint5PoiIconStyle = PoiIconStyle(symbol: wayPointsPoiView[4].asImage(), anchorPoint: CGPoint(x: 0.5, y: 1))
        let wayPoint5PoiStyle = PerLevelPoiStyle(iconStyle: wayPoint5PoiIconStyle)
        
        //도착지
        let destinationPoiIconStyle = PoiIconStyle(symbol: destinationPlacePoiView.asImage(), anchorPoint: CGPoint(x: 0.5, y: 1))
        let destinationPoiStyle = PerLevelPoiStyle(iconStyle: destinationPoiIconStyle)
        
        let startPlaceStyle = PoiStyle(styleID: "startPlaceStyle", styles: [startPlacePoiStyle])
        
        let wayPoint1Style = PoiStyle(styleID: "wayPoint1Style", styles: [wayPoint1PoiStyle])
        let wayPoint2Style = PoiStyle(styleID: "wayPoint2Style", styles: [wayPoint2PoiStyle])
        let wayPoint3Style = PoiStyle(styleID: "wayPoint3Style", styles: [wayPoint3PoiStyle])
        let wayPoint4Style = PoiStyle(styleID: "wayPoint4Style", styles: [wayPoint4PoiStyle])
        let wayPoint5Style = PoiStyle(styleID: "wayPoint5Style", styles: [wayPoint5PoiStyle])

        let destinationStyle = PoiStyle(styleID: "destinationStyle", styles: [destinationPoiStyle])
        
        manager.addPoiStyle(startPlaceStyle)
        manager.addPoiStyle(wayPoint1Style)
        manager.addPoiStyle(wayPoint2Style)
        manager.addPoiStyle(wayPoint3Style)
        manager.addPoiStyle(wayPoint4Style)
        manager.addPoiStyle(wayPoint5Style)
        manager.addPoiStyle(destinationStyle)

    }
    
    func createCurrentLocationPoi(_ location: CLLocation) {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "CurrentLocationPoiLayer")
        let poiOption = PoiOptions(styleID: "CurrentLocationStyle")
        
        poiOption.rank = 0
        poiOption.clickable = true
        
        let poi = layer?.addPoi(option: poiOption, at: MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude))
        
        currentLocationPoi = poi
        currentLocationPoi?.show()
    }
    
    func createPlaceDetailPoi(coordinate: (longitude: Double, latitude: Double), placeName: String) {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PlaceDetailPoiLayer")
        let poiOption = PoiOptions(styleID: "PlaceDetailStyle")
        
        poiOption.rank = 1
        
        let poi = layer?.addPoi(option: poiOption, at: MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude))
        
        if let id = placeDetailPoiID {
            layer?.removePoi(poiID: id)
        }
        
        placeDetailPoiID = poi?.itemID
        poi?.show()
    }
    
    func removePlaceDetailPoi() {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PlaceDetailPoiLayer")
        
        if let id = placeDetailPoiID {
            layer?.removePoi(poiID: id)
        }
    }
    
    func createRoutePois(_ route: [RouteSectionItem]) {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "RoutePoiLayer")
        let startPlacePoiOption = PoiOptions(styleID: "startPlaceStyle")
        let wayPoint1PoiOption = PoiOptions(styleID: "wayPoint1Style")
        let wayPoint2PoiOption = PoiOptions(styleID: "wayPoint2Style")
        let wayPoint3PoiOption = PoiOptions(styleID: "wayPoint3Style")
        let wayPoint4PoiOption = PoiOptions(styleID: "wayPoint4Style")
        let wayPoint5PoiOption = PoiOptions(styleID: "wayPoint5Style")
        let destinationPoiOption = PoiOptions(styleID: "destinationStyle")

        let wayPointOptions: [PoiOptions] = [wayPoint1PoiOption, wayPoint2PoiOption, wayPoint3PoiOption, wayPoint4PoiOption, wayPoint5PoiOption]
        
        var wayPointFlag = 1
        
        for place in route {
            if let point = place.place {
                switch place.role {
                case .start:
                    if !routePoisID[0].isEmpty {
                        layer?.removePoi(poiID: routePoisID[0])
                    }
                    
                    let poi = layer?.addPoi(option: startPlacePoiOption, at: MapPoint(longitude: point.longitude, latitude: point.latitude))
            
                    if let id = poi?.itemID {
                        routePoisID[0] = id
                    }
                    
                    poi?.show()
                case .wayPoints:
                    let index = wayPointFlag
                    let option = wayPointOptions[index - 1]
                    
                    if !routePoisID[index].isEmpty {
                        layer?.removePoi(poiID: routePoisID[index])
                    }
                    
                    let poi = layer?.addPoi(option: option, at: MapPoint(longitude: point.longitude, latitude: point.latitude))
            
                    if let id = poi?.itemID {
                        routePoisID[index] = id
                    }
                    
                    poi?.show()
                    wayPointFlag += 1
                    
                case .destination:
                    if !routePoisID[6].isEmpty {
                        layer?.removePoi(poiID: routePoisID[6])
                    }
                    
                    let poi = layer?.addPoi(option: destinationPoiOption, at: MapPoint(longitude: point.longitude, latitude: point.latitude))
                    
                    if let id = poi?.itemID {
                        routePoisID[6] = id
                    }
                    
                    poi?.show()
                }
                
            }
        }
        
    }
    
    func removeRoutePois() {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "RoutePoiLayer")
        
        layer?.removePois(poiIDs: routePoisID)
    }
}
