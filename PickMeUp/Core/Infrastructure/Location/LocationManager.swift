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
    private let locationManager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isLoading = false
    @Published var errorMessage: String?

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
        }
    }

    private func clearError() {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = nil
        }
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
