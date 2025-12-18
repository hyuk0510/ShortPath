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
            isButtonActive = false
            updateGuiUI()
        }
    }
    
    func updateCameraEventHandler() {
        kakaoMap.eventDelegate = self
    }
}
