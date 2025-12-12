//
//  Map+Poi.swift
//  ShortPath
//
//  Created by 선상혁 on 12/12/25.
//

import UIKit
import KakaoMapsSDK

extension MapViewController {
    
    func createLabelLayer() {
        let manager = kakaoMap.getLabelManager()
        
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10001)
        let _ = manager.addLabelLayer(option: layerOption)
    }
    
    func createPoiStyle() {
        let manager = kakaoMap.getLabelManager()
        
        let red = TextStyle(fontSize: 20, fontColor: UIColor.white, strokeThickness: 2, strokeColor: UIColor.red)
        let blue = TextStyle(fontSize: 20, fontColor: UIColor.white, strokeThickness: 2, strokeColor: UIColor.blue)
        
        let textStyle1 = PoiTextStyle(textLineStyles: [
            PoiTextLineStyle(textStyle: red)
        ])
        let textStyle2 = PoiTextStyle(textLineStyles: [
            PoiTextLineStyle(textStyle: blue)
        ])
        
        let noti = PoiBadge(badgeID: "badge1", image: poiBadgeView.asImage(), offset: CGPoint(x: 0.9, y: 0.1), zOrder: 0)
        let iconStyle = PoiIconStyle(symbol: poiView.asImage(), anchorPoint: CGPoint(x: 0.5, y: 0.0), badges: [noti])
        let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, textStyle: textStyle1, level: 0)
        let poiStyle = PoiStyle(styleID: "customStyle1", styles: [perLevelStyle])
        manager.addPoiStyle(poiStyle)
    }
    
    func createPois() {
        let manager = kakaoMap.getLabelManager()
        
        let layer = manager.getLabelLayer(layerID: "PoiLayer")
        let poiOption = PoiOptions(styleID: "customStyle1")
        poiOption.rank = 0
        
        poiOption.addText(PoiText(text: "testPoi", styleIndex: 0))
        poiOption.clickable = true
        
        let poi1 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: 126.9136, latitude: 37.5493))
        
        poi1?.show()
    }
}
