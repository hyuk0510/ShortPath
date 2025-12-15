//
//  Map+SpriteGUI.swift
//  ShortPath
//
//  Created by 선상혁 on 12/12/25.
//

import UIKit
import KakaoMapsSDK

extension MapViewController {
    
    func createSpriteGUI() {
        let spriteLayer = kakaoMap.getGuiManager().spriteGuiLayer
        let spriteGUI = SpriteGui("SpriteGUI")
        
        spriteGUI.arrangement = .horizontal
        spriteGUI.bgColor = UIColor.green
        spriteGUI.splitLineColor = UIColor.white
        
        spriteGUI.origin = GuiAlignment(vAlign: .bottom, hAlign: .right)
        spriteGUI.position = CGPoint(x: 50, y: 100)
        
        let button = GuiButton("track_location")
        button.image = UIImage(systemName: "star")
        
        spriteGUI.addChild(button)
        
        let _ = spriteLayer.addSpriteGui(spriteGUI)
        spriteGUI.delegate = self
        spriteGUI.show()
    }
    
    func guiDidTapped(_ gui: KakaoMapsSDK.GuiBase, componentName: String) {
        NSLog("Gui: \(gui.name), Componenet: \(componentName) Tapped")
        
        let guiText = gui.getChild("track_location") as? GuiText
        
        locationManager.requestLocation()
        
        if let location = locationManager.location {
            moveCameraToCurrentLocation(location)
            createPois(location)
        }
        
        gui.updateGui()
        
        
    }
}
