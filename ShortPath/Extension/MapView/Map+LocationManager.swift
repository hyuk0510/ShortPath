//
//  Map+LocationManager.swift
//  ShortPath
//
//  Created by 선상혁 on 12/14/25.
//

import UIKit
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
