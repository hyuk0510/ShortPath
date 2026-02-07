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
            isGUIButtonActive = false
            updateGuiUI()
            
            isPanned = true
            mapInterActiveDelegate?.mapDidReceiveUserInteraction()
        }
    }
    
    func updateCameraEventHandler() {
        kakaoMap?.eventDelegate = self
    }
    
    func kakaoMapDidTapped(kakaoMap: KakaoMap, point: CGPoint) {
        if isGUIButtonActive {
            return
        }
        mapInterActiveDelegate?.mapDidReceiveUserInteraction()
    }
    
    
}
