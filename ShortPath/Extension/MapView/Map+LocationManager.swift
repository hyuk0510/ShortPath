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
        locationManager.headingFilter = 3
        locationManager.startUpdatingHeading()
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
                DispatchQueue.main.async {
                    self.errorAlert(title: "위치 정보 서비스 불가", message: "위치 정보 서비스를 이용할 수 없습니다.")
                }
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
//            locationManager.requestLocation()
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
    
    func getCurrentAddress() async -> String? {
        if let currentAddress {
            return currentAddress
        }
        
        guard let location = currentLocation else { return nil }
            
            do {
                let address = try await KakaoLocalManager.shared.fetchCurrentAddress(coordinate: location.coordinate)
                
                let document = address.documents.first
                let roadAddress = document?.roadAddress?.addressName
                let lotNumberAddress = document?.address.addressName
                
                let resolvedAddress = (roadAddress?.isEmpty == false) ? roadAddress : lotNumberAddress
                
                await MainActor.run {
                    self.currentAddress = resolvedAddress
                    self.addressBaseLocation = location
                    
                }
                
                return resolvedAddress
            } catch {
                print("❌ current address fetch failed:", error)
                return nil
            }

    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let isFirstLocation = !hasInitialLocation
        
        currentLocation = location
        updateCurrentLocationPoi(location)
        
        if isFirstLocation {
            mapInterActiveDelegate?.didUpdateCurrentLocation(location)
        }
        
        guard kakaoMap != nil else { return }
        
        if !hasInitialLocation {
            hasInitialLocation = true
            
            moveCameraToCurrentLocation()
            
            addressTask?.cancel()
            addressTask = Task { [weak self] in
                guard let self else { return }
                
                _ = await self.getCurrentAddress()
            }
            
            return
        }
        
        if let baseLocation = addressBaseLocation,
           location.distance(from: baseLocation) > 50 {
            currentAddress = nil
            addressBaseLocation = nil
            
            mapInterActiveDelegate?.didUpdateCurrentLocation(location)

            addressTask?.cancel()
            addressTask = Task { [weak self] in
                guard let self else { return }
                
                _ = await self.getCurrentAddress()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = newHeading.trueHeading >= 0
        
        ? newHeading.trueHeading
        
        : newHeading.magneticHeading
        
        guard heading >= 0 else { return }
        
        updateCurrentLocationDirection(heading: heading)
    }
    
    private func updateCurrentLocationDirection(heading: CLLocationDirection) {
        let correctedHeading = heading
        let angle = correctedHeading * .pi / 180
        
        currentLocationPoi?.rotateAt(
            Double(Float(angle)),
            duration: 200
        )
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        let clError = error as? CLError
        
        if clError?.code == .locationUnknown {
            return
        }
        
        if UIApplication.shared.applicationState == .active {
            errorAlert(title: "위치 정보 에러", message: "위치 정보를 가져오지 못하였습니다.")
        }
    }
    
    func moveCameraToCurrentLocation(sheetMode: SheetMode = .home) {
        guard let location = currentLocation else { return }
        guard let kakaoMap = kakaoMap else { return }
        
        let currentPosition = MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
        let cameraUpdate = CameraUpdate.make(target: currentPosition, mapView: kakaoMap)
        
        kakaoMap.moveCamera(cameraUpdate)
        
        if sheetMode == .routing(.ready) {
            positionLogo(128)
        }
    }
    
    func updateCurrentLocationPoi(_ location: CLLocation) {
        if let currentPoi = currentLocationPoi {
            currentPoi.position = MapPoint(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
        }
    }
    
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        guard let to = currentLocation else { return CLLocationDistance() }
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        
        return from.distance(from: to)
    }
}

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        return from.distance(from: to)
    }
}
