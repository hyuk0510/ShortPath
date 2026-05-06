//
//  Map+EventHandler.swift
//  ShortPath
//
//  Created by 선상혁 on 12/18/25.
//

import UIKit
import KakaoMapsSDK

extension MapViewController: KakaoMapEventDelegate {
    func cameraWillMove(kakaoMap: KakaoMap, by: MoveBy) {
        if by == .pan {
            mapInterActiveDelegate?.mapDidReceiveUserInteraction(type: .pan)
            isPanned = true
        }
        
        if by == .zoom {
            mapInterActiveDelegate?.mapDidReceiveUserInteraction(type: .zoom)
        }
    }
    
    func updateCameraEventHandler() {
        kakaoMap?.eventDelegate = self
    }
    
    func kakaoMapDidTapped(kakaoMap: KakaoMap, point: CGPoint) {
        mapInterActiveDelegate?.mapDidReceiveUserInteraction(type: .tap)
    }
    
    func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
        guard let place = repository.fetch(placeID: layerID) else { return }
                
        mapInterActiveDelegate?.favoritePoiTapped(place: place)
    }
}
