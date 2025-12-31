//
//  Map+LifeCycle.swift
//  ShortPath
//
//  Created by 선상혁 on 12/12/25.
//

import UIKit
import KakaoMapsSDK

extension MapViewController {
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        _appear = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if mapController == nil {
            addViews()
        }
        
        mapController?.activateEngine()
        
        guard let sheet = presentingViewController?.sheetPresentationController, let containerView = sheet.containerView, let mapPan = mapView.gestureRecognizers?.first(where: { $0 is UIPanGestureRecognizer}) else { return }
    
        for gesture in containerView.gestureRecognizers ?? [] {
            if gesture is UIPanGestureRecognizer {
                mapPan.require(toFail: gesture)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        _appear = false
        mapController?.pauseEngine()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        mapController?.resetEngine()
    }
}
