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
        
        spriteGui.arrangement = .horizontal
        spriteGui.bgColor = UIColor.clear
        spriteGui.splitLineColor = UIColor.white
        
        spriteGui.origin = GuiAlignment(vAlign: .bottom, hAlign: .right)
        spriteGui.position = CGPoint(x: 50, y: 100)
        
        normalImage = makeCirculaerButtonImage(iconAlpha: 0.2)
        tappedImage = makeCirculaerButtonImage(iconAlpha: 1.0)
        
        button.image = tappedImage
        
        spriteGui.addChild(button)
        
        let _ = spriteLayer.addSpriteGui(spriteGui)
        spriteGui.delegate = self
        spriteGui.show()
    }
    
    func guiDidTapped(_ gui: KakaoMapsSDK.GuiBase, componentName: String) {
        NSLog("Gui: \(gui.name), Componenet: \(componentName) Tapped")
        
        let guiText = gui.getChild("track_location") as? GuiText
        locationManager.requestLocation()
        
        isButtonActive = true
        updateGuiUI()
        
        if let location = locationManager.location {
            moveCameraToCurrentLocation(location)
        }
    }
    
    func updateGuiUI() {
        button.image = isButtonActive ? tappedImage: normalImage
        spriteGui.updateGui()
    }
    
}
