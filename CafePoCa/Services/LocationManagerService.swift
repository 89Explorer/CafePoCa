//
//  LocationManagerService.swift
//  CafePoCa
//
//  Created by 권정근 on 6/9/25.
//

import Foundation
import UIKit
import CoreLocation


final class LocationManagerService: NSObject, CLLocationManagerDelegate {
    
    
    // MARK: - Variable
    static let shared = LocationManagerService()
    
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    var onUpdateAddress: ((String, CLLocationCoordinate2D) -> Void)?
    var onFail: ((String) -> Void)?
    
    
    // MARK: - Init
    override init() {
        super.init()
        manager.delegate = self
    }
    
    
    // MARK: - Function
    func requestAuthorization() {
        guard CLLocationManager.locationServicesEnabled() else {
            onFail?("위치 서비스가 꺼져 있습니다.")
            return
        }
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorization(manager.authorizationStatus)
    }
    
    private func handleAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            onFail?("LocationDenied")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        reverseGeoCode(location: location)
        //fetchAddressFromCoordinates(location.coordinate)
        manager.stopUpdatingLocation()
    }
    
    private func reverseGeoCode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let placemark = placemarks?.first {
                var addressComponents: [String] = []
                // 주/지역명 추가 (도시명과 동일하지 않은 경우에만 추가)
                if let administrativeArea = placemark.administrativeArea, administrativeArea != placemark.locality {
                    addressComponents.append(administrativeArea)
                }

                // 도시명 추가
                if let locality = placemark.locality {
                    addressComponents.append(locality)
                }

                // 도로명 주소 또는 지번 주소 추가 (도로명 주소가 있는 경우 우선적으로 추가)
                if let thoroughfare = placemark.thoroughfare {
                    addressComponents.append(thoroughfare)
                    if let subThoroughfare = placemark.subThoroughfare {
                        addressComponents.append(subThoroughfare)
                    }
                } else if let name = placemark.name, !addressComponents.contains(name) {
                    // 도로명 주소가 없고 지번 주소가 이미 추가된 주소 구성 요소에 포함되지 않은 경우 지번 주소 추가
                    addressComponents.append(name)
                }

                let addressString = addressComponents.joined(separator: " ")
                let coordinate = location.coordinate
                self.onUpdateAddress?(addressString, coordinate)
            } else {
                self.onFail?("주소 변환에 실패했습니다.")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onFail?("위치 정보를 가져오지 못했습니다.")
    }
    
    // `reloadData` 대체용 (선택사항)
    private func reloadDataIfNeeded() {
        // 권한이 거부된 후 UI를 갱신하거나 데이터를 다시 로드하고 싶다면 여기에 작성
        print("🔄 위치 권한 거부: UI 갱신 필요 시 이곳에서 처리")
    }
    
    func setHandlers(
        onUpdate: @escaping (String, CLLocationCoordinate2D) -> Void,
        onFail: @escaping (String) -> Void
    ) {
        self.onUpdateAddress = onUpdate
        self.onFail = onFail
    }
}
