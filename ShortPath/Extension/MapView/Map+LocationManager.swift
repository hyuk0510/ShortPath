//
//  Map+LocationManager.swift
//  ShortPath
//
//  Created by 선상혁 on 12/14/25.
//

import UIKit
import KakaoMapsSDK
import CoreLocation

extension MapViewController {
    
    func setLM() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkDeviceLocationAuthorization() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                
                let authorization: CLAuthorizationStatus
                
                authorization = self.locationManager.authorizationStatus
                
                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorizationStatus(status: authorization)
                }
            } else {
                self.errorAlert(title: "위치 정보 서비스 불가", message: "위치 정보 서비스를 이용할 수 없습니다.")
            }
        }
    }
    
    func checkCurrentLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showSettingAlert()
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            locationManager.startUpdatingLocation()
        @unknown default:
            self.errorAlert(title: "GPS 오류", message: "GPS 연결을 확인해주세요.")
        }
    }
    
    func showSettingAlert() {
        let alert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 이용할 수 없습니다. '설정 -> 개인정보 보호'에서 위치 서비스를 켜주세요", preferredStyle: .alert)
        let setting = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let setting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(setting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(setting)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            updateCurrentLocationPoi(location)
            
            if let _ = currentLocation {
                hasInitialLocation = true
            }
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("ERROR, 위치 정보를 가져오기 못하였습니다.")
    }
    
//    func firstCameraMove(bottomSheetY: CGFloat) {
//        if !isPanned {
//            containerDidResized(CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - bottomSheetY))
//        }
//    }
    
    func moveCameraToCurrentLocation() {
        guard let location = currentLocation else { return }
        
        let currentPosition = MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
        
        kakaoMap?.moveCamera(CameraUpdate.make(target: currentPosition, zoomLevel: 17, mapView: kakaoMap!))
    }
    
    func updateCurrentLocationPoi(_ location: CLLocation) {
        if let currentPoi = currentLocationPoi {
            currentPoi.position = MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
        }
    }
}
