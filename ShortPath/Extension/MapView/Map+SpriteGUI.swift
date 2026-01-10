//
//  Map+SpriteGUI.swift
//  ShortPath
//
//  Created by 선상혁 on 12/12/25.
//

import UIKit
import KakaoMapsSDK

extension MapViewController: GuiEventDelegate {
        
    func createSpriteGUI() {
        let spriteLayer = kakaoMap.getGuiManager().spriteGuiLayer
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let safeAreaBottom = windowScene?.windows.first?.safeAreaInsets.bottom ?? 0
        
        spriteGui.arrangement = .horizontal
        spriteGui.bgColor = UIColor.clear
        spriteGui.splitLineColor = UIColor.white
        
        spriteGui.origin = GuiAlignment(vAlign: .bottom, hAlign: .right)
        spriteGui.position = CGPoint(x: 30, y: 200)
        
        normalImage = makeCirculaerButtonImage(iconAlpha: 0.2)
        tappedImage = makeCirculaerButtonImage(iconAlpha: 1.0)
        
        button.image = tappedImage
        
        spriteGui.addChild(button)
        
        let _ = spriteLayer.addSpriteGui(spriteGui)
        spriteGui.delegate = self
        spriteGui.show()
    }
    
    func guiDidTapped(_ gui: KakaoMapsSDK.GuiBase, componentName: String) {
        locationManager.requestLocation()
        
        isGUIButtonActive = true
        updateGuiUI()
        
        if let location = locationManager.location {
            moveCameraToCurrentLocation(location)
        }
    }
    
    func updateGuiUI() {
        button.image = isGUIButtonActive ? tappedImage: normalImage
        spriteGui.updateGui()
    }
    
}
