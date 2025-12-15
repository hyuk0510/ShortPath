//
//  ViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 11/29/25.
//

import UIKit
import KakaoMapsSDK
import CoreLocation

final class MapViewController: UIViewController, MapControllerDelegate, GuiEventDelegate {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _observerAdded = false
        _auth = false
        _appear = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        _observerAdded = false
        _auth = false
        _appear = false
        super.init(coder: aDecoder)
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        
        print("deinit")
    }
    
    lazy var mapView: KMViewContainer = {
            let view = KMViewContainer()
            return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        mapSetupUI()
        addViews()
        setLM()
        checkDeviceLocationAuthorization()
    }
    
    var mapContainer: KMViewContainer?
    var mapController: KMController?
    lazy var kakaoMap: KakaoMap = mapController?.getView("mapview") as! KakaoMap
    var _observerAdded: Bool = false
    var _auth: Bool = false
    var _appear: Bool = false
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var lot: Double?
    var lat: Double?
    var currentLocation: CLLocation?
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("ERROR, 위치 정보를 가져오기 못하였습니다.")
    }
    
    func moveCameraToCurrentLocation(_ location: CLLocation) {
        let currentPosition = MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
        
        kakaoMap.moveCamera(CameraUpdate.make(target: currentPosition, zoomLevel: 17, mapView: kakaoMap))
    }
}
