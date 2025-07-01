//
//  LocationManager.swift
//  PickMeUp
//
//  Created by 김태형 on 6/29/25.
//


import CoreLocation
import SwiftUI

// MARK: - Location Manager
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager() // 싱글톤 추가

    private let locationManager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 추가: 선택된 주소 정보
    @Published var selectedLocation: SelectedLocationInfo?

    var locationUpdateHandler: ((CLLocation) -> Void)?
    var errorHandler: ((String) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Methods

    /// 위치 권한을 요청하거나 확인합니다
    /// - Returns: 즉시 위치 업데이트가 시작되었는지 여부
    @discardableResult
    func requestLocationPermission() -> Bool {
        clearError() // 이전 오류 메시지 클리어

        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return false // 권한 요청 중
        case .denied, .restricted:
            let message = "위치 권한이 거부되었습니다. 설정에서 위치 권한을 허용해주세요."
            handleError(message)
            return false
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdate()
            return true
        @unknown default:
            return false
        }
    }

    /// 현재 위치 업데이트를 시작합니다 (권한이 있는 경우에만)
    func getCurrentLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        startLocationUpdate()
    }

    /// 위치 업데이트를 중지합니다
    func stopLocationUpdate() {
        locationManager.stopUpdatingLocation()
        isLoading = false
    }

    /// 설정 앱으로 이동합니다
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            handleError("설정 앱을 열 수 없습니다.")
            return
        }
        UIApplication.shared.open(settingsUrl)
    }

    // MARK: - 추가: 주소 선택 관련 메서드

    /// 사용자가 선택한 주소로 위치를 업데이트합니다
    func updateSelectedLocation(name: String, type: LocationType, latitude: Double, longitude: Double, address: String, detailAddress: String?) {
        let newLocation = SelectedLocationInfo(
            name: name,
            type: type,
            latitude: latitude,
            longitude: longitude,
            address: address,
            detailAddress: detailAddress
        )

        selectedLocation = newLocation
        currentLocation = CLLocation(latitude: latitude, longitude: longitude)

        print("📍 위치 업데이트됨: \(name) (\(latitude), \(longitude))")
    }

    /// 현재 GPS 위치를 선택된 위치로 설정합니다
    func useCurrentLocationAsSelected() {
        guard let location = currentLocation else {
            handleError("현재 위치를 찾을 수 없습니다.")
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    let address = self?.formatAddress(from: placemark) ?? "주소를 찾을 수 없습니다"

                    self?.selectedLocation = SelectedLocationInfo(
                        name: "현재 위치",
                        type: .custom,
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        address: address,
                        detailAddress: nil
                    )

                    print("📍 현재 위치로 설정됨: \(address)")
                } else {
                    self?.selectedLocation = SelectedLocationInfo(
                        name: "현재 위치",
                        type: .custom,
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        address: "위도: \(String(format: "%.6f", location.coordinate.latitude)), 경도: \(String(format: "%.6f", location.coordinate.longitude))",
                        detailAddress: nil
                    )
                }
            }
        }
    }

    /// 선택된 위치를 초기화합니다
    func clearSelectedLocation() {
        selectedLocation = nil
        print("📍 선택된 위치 초기화됨")
    }

    // MARK: - Private Methods

    private func startLocationUpdate() {
        clearError()
        isLoading = true
        locationManager.startUpdatingLocation()
    }

    private func handleError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = message
            self?.errorHandler?(message)
            self?.isLoading = false
        }
    }

    private func clearError() {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = nil
        }
    }

    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []

        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        if let subLocality = placemark.subLocality {
            addressComponents.append(subLocality)
        }
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        if let subThoroughfare = placemark.subThoroughfare {
            addressComponents.append(subThoroughfare)
        }

        return addressComponents.joined(separator: " ")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = manager.authorizationStatus

            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self?.startLocationUpdate()
            case .denied, .restricted:
                self?.isLoading = false
                self?.handleError("위치 권한이 필요합니다.")
            case .notDetermined:
                self?.isLoading = false
            @unknown default:
                self?.isLoading = false
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async { [weak self] in
            self?.currentLocation = location
            self?.isLoading = false
            self?.clearError()
        }

        locationManager.stopUpdatingLocation()
        locationUpdateHandler?(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }

        let message: String
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                message = "위치 권한이 거부되었습니다."
            case .locationUnknown:
                message = "현재 위치를 찾을 수 없습니다."
            case .network:
                message = "네트워크 오류로 위치를 가져올 수 없습니다."
            default:
                message = "위치 정보를 가져오는데 실패했습니다."
            }
        } else {
            message = "위치를 가져올 수 없습니다: \(error.localizedDescription)"
        }

        handleError(message)
    }
}



// MARK: - 선택된 위치 정보 모델
struct SelectedLocationInfo: Equatable {
    let name: String
    let type: LocationType
    let latitude: Double
    let longitude: Double
    let address: String
    let detailAddress: String?

    var displayName: String {
        return name
    }

    var fullAddress: String {
        if let detail = detailAddress, !detail.isEmpty {
            return "\(address) \(detail)"
        }
        return address
    }

    var coordinates: (latitude: Double, longitude: Double) {
        return (latitude, longitude)
    }

    var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    // Equatable 구현
    static func == (lhs: SelectedLocationInfo, rhs: SelectedLocationInfo) -> Bool {
        return lhs.name == rhs.name &&
               lhs.type == rhs.type &&
               lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude &&
               lhs.address == rhs.address &&
               lhs.detailAddress == rhs.detailAddress
    }
}

