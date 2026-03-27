//
//  Map+Route.swift
//  ShortPath
//
//  Created by 선상혁 on 3/25/26.
//

import UIKit
import KakaoMapsSDK

extension MapViewController {
    func createRouteStyle() {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getRouteManager()
        let _ = manager.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        let patternImage = UIImage(named: "RoutePatternImage") ?? UIImage()
        
        let styleSet = RouteStyleSet(styleID: "routeStyleSet")
        
        styleSet.addPattern(RoutePattern(pattern: patternImage, distance: 60, symbol: nil, pinStart: true, pinEnd: true))
        
        let routeColor = UIColor(hex: "0x3B82F6")
        let strokeColor = UIColor(hex: "0x1F2937")
        
        let routeStyle = RouteStyle(styles: [PerLevelRouteStyle(width: 18, color: routeColor, strokeWidth: 4, strokeColor: strokeColor, level: 0, patternIndex: 0)])
        
        styleSet.addStyle(routeStyle)
        
        manager.addRouteStyleSet(styleSet)
    }
    
    func createRouteLine(_ sections: [Section]) {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getRouteManager()
        let layer = manager.getRouteLayer(layerID: "RouteLayer")
        
        var mapPoints: [MapPoint] = []

        for section in sections {
            for road in section.roads {
                let v = road.vertexes
                
                var i = 0
                
                while i < v.count {
                    let x = v[i]
                    let y = v[i + 1]
                    
                    mapPoints.append(MapPoint(longitude: x, latitude: y))
                    
                    i += 2
                }
            }
        }
        
        let option = RouteOptions(
            routeID: "mainRoute",
            styleID: "routeStyleSet",
            zOrder: 0
        )

        let segment = RouteSegment(points: mapPoints, styleIndex: 0)

        option.segments = [segment]

        let route = layer?.addRoute(option: option)
        route?.show()
        
    }
    
    func removeRoute() {
        guard let kakaoMap = kakaoMap else { return }
        
        let manager = kakaoMap.getRouteManager()
        let layer = manager.getRouteLayer(layerID: "RouteLayer")
    
        layer?.removeRoute(routeID: "mainRoute")
        
    }
}
