//
//  Map+Layout.swift
//  ShortPath
//
//  Created by 선상혁 on 12/12/25.
//

import UIKit
import KakaoMapsSDK
import SnapKit

extension MapViewController {
    
    func mapSetupUI() {
        view.backgroundColor = .white
        
        [mapView].forEach {
            self.view.addSubview($0)
        }
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
//        button.snp.makeConstraints { make in
//            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
//            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
//            make.size.equalTo(50)
//        }
//
//        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        
    }
    
    func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 126.9137, latitude: 37.5491)
        let mapViewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 17)
        
        mapContainer = mapView
        
        mapController = KMController(viewContainer: mapContainer!)
        mapController!.delegate = self
        
        mapController?.prepareEngine()
        
        DispatchQueue.main.async {
            self.mapController?.addView(mapViewInfo)
        }
    }
    
    func viewInit(viewName: String) {
        print("OK")
        
        createLabelLayer()
        createPoiStyle()
        createPois()
        createSpriteGUI()
    }
    
    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("OK")
        
        kakaoMap.viewRect = mapContainer!.bounds    //뷰 add 도중에 resize 이벤트가 발생한 경우 이벤트를 받지 못했을 수 있음. 원하는 뷰 사이즈로 재조정.
        viewInit(viewName: viewName)
    }
    
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }
    
    func containerDidResized(_ size: CGSize) {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
    }
}
