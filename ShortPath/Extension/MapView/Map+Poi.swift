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
        let _ = manager.addLabelLayer(option: currentLocationLayerOption)
        let _ = manager.addLabelLayer(option: placeDetailLayerOption)
    }
    
    func createPoiStyle() {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getLabelManager()
        
        // 현재 위치 Poi
        let red = TextStyle(fontSize: 20, fontColor: UIColor.white, strokeThickness: 2, strokeColor: UIColor.red)
        let currentLocationTextStyle = PoiTextStyle(textLineStyles: [
            PoiTextLineStyle(textStyle: red)
        ])
        
        let noti = PoiBadge(badgeID: "badge1", image: currentLocationPoiBadgeView.asImage(), offset: CGPoint(x: 0.9, y: 0.1), zOrder: 0)
        let currentLocationIconStyle = PoiIconStyle(symbol: currentLocationPoiView.asImage(), anchorPoint: CGPoint(x: 0.5, y: 0.5), badges: [noti])
        let perLevelCurrentLocationStyle = PerLevelPoiStyle(iconStyle: currentLocationIconStyle, textStyle: currentLocationTextStyle, level: 0)
        let currentLocationStyle = PoiStyle(styleID: "CurrentLocationStyle", styles: [perLevelCurrentLocationStyle])
        
        manager.addPoiStyle(currentLocationStyle)
        
        // 장소 위치 Poi
        let placeDetailIconStyle = PoiIconStyle(symbol: placeDetailPoiView.asImage(), anchorPoint: CGPoint(x: 0.5, y: 1))
        let perLevelPlaceDetailStyle = PerLevelPoiStyle(iconStyle: placeDetailIconStyle)
        let placeDetailStyle = PoiStyle(styleID: "PlaceDetailStyle", styles: [perLevelPlaceDetailStyle])
        
        manager.addPoiStyle(placeDetailStyle)
    }
    
    func createCurrentLocationPoi(_ location: CLLocation) {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "CurrentLocationPoiLayer")
        let poiOption = PoiOptions(styleID: "CurrentLocationStyle")
        
        poiOption.rank = 0
        poiOption.addText(PoiText(text: "현재 위치", styleIndex: 0))
        poiOption.clickable = true
        
        let poi = layer?.addPoi(option: poiOption, at: MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude))
        
        currentLocationPoi = poi
        currentLocationPoi?.show()
        
//        currentLocationPoi?.addPoiTappedEventHandler(target: <#T##AnyObject#>, handler: <#T##(AnyObject) -> (PoiInteractionEventParam) -> Void#>)
    }
    
    func createPlaceDetailPoi(coordinate: (longitude: Double, latitude: Double)) {
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
}
