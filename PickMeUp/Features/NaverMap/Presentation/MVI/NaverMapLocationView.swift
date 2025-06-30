//
//  NaverMapLocationView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/30/25.
//

import CoreLocation
import SwiftUI
import NMapsMap

// MARK: - Constants
private enum MapConstants {
    static let defaultZoom: Double = 16
    static let seoulCoordinate = CLLocationCoordinate2D(latitude: 37.5666805, longitude: 126.9784147)
    static let buttonHeight: CGFloat = 50
    static let horizontalPadding: CGFloat = 20
    static let bottomPadding: CGFloat = 20
    static let mapButtonSpacing: CGFloat = 20
}

// MARK: - Map Marker Types
enum MapMarkerType {
    case currentLocation
    case centerPin
    case selectedLocation
}

struct NaverMapLocationView: UIViewRepresentable {
    let initialLocation: CLLocationCoordinate2D?
    let currentLocation: CLLocationCoordinate2D?
    let onLocationSelected: (CLLocationCoordinate2D, String) -> Void
    let onDismiss: () -> Void

    func makeUIView(context: Context) -> UIView {
        let coordinator = context.coordinator
        return coordinator.createMapContainer()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.updateCurrentLocation(currentLocation)
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(
            initialLocation: initialLocation,
            currentLocation: currentLocation,
            onLocationSelected: onLocationSelected,
            onDismiss: onDismiss
        )
    }
}

// MARK: - Map Coordinator
final class MapCoordinator: NSObject {
    private let initialLocation: CLLocationCoordinate2D?
    private var currentLocation: CLLocationCoordinate2D?
    private let onLocationSelected: (CLLocationCoordinate2D, String) -> Void
    private let onDismiss: () -> Void

    // Map components
    private var mapView: NMFMapView?
    private var currentLocationMarker: NMFMarker?
    private var centerPinMarker: NMFMarker?
    private var selectedCoordinate: CLLocationCoordinate2D?

    init(
        initialLocation: CLLocationCoordinate2D?,
        currentLocation: CLLocationCoordinate2D?,
        onLocationSelected: @escaping (CLLocationCoordinate2D, String) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.initialLocation = initialLocation
        self.currentLocation = currentLocation
        self.onLocationSelected = onLocationSelected
        self.onDismiss = onDismiss
        super.init()
    }

    func createMapContainer() -> UIView {
        // 네이버 지도 SDK 초기화 상태 확인
        guard NaverMapConfiguration.shared.isReady else {
            print("❌ NaverMap not initialized properly")
            return createErrorView()
        }

        let containerView = UIView()
        let mapView = createMapView()
        let confirmButton = createConfirmButton()

        setupLayout(in: containerView, mapView: mapView, confirmButton: confirmButton)
        setupMapComponents(mapView)

        self.mapView = mapView
        return containerView
    }

    func updateCurrentLocation(_ newLocation: CLLocationCoordinate2D?) {
        guard let mapView = mapView else { return }

        self.currentLocation = newLocation
        updateCurrentLocationMarker(newLocation)

        // 현재 위치가 업데이트되면 지도 중심을 현재 위치로 이동 (선택적)
        if let location = newLocation {
            moveMapToLocation(location, animated: true)
        }
    }

    private func createMapView() -> NMFMapView {
        let mapView = NMFMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false

        // 초기 위치 설정 (현재 위치 → 초기 위치 → 기본 위치 순)
        let coordinate = currentLocation ?? initialLocation ?? MapConstants.seoulCoordinate
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoom: MapConstants.defaultZoom
        )
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))

        return mapView
    }

    private func setupMapComponents(_ mapView: NMFMapView) {
        // 카메라 델리게이트 설정
        mapView.addCameraDelegate(delegate: self)

        // 중앙 핀 마커 설정
        setupCenterPinMarker(mapView)

        // 현재 위치 마커 설정
        setupCurrentLocationMarker(mapView)

        // 초기 선택 좌표 설정
        updateSelectedCoordinate(mapView.cameraPosition.target)
    }

    private func setupCenterPinMarker(_ mapView: NMFMapView) {
        let marker = NMFMarker()
        marker.position = mapView.cameraPosition.target
        marker.iconImage = NMFOverlayImage(name: "ic_map_pin")
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
        marker.mapView = mapView
        self.centerPinMarker = marker
    }

    private func setupCurrentLocationMarker(_ mapView: NMFMapView) {
        guard let currentLocation = currentLocation else { return }

        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: currentLocation.latitude, lng: currentLocation.longitude)
        marker.iconImage = createCurrentLocationIcon()
        marker.anchor = CGPoint(x: 0.5, y: 0.5) // 중앙 정렬
        marker.mapView = mapView
        self.currentLocationMarker = marker
    }

    private func updateCurrentLocationMarker(_ location: CLLocationCoordinate2D?) {
        guard let mapView = mapView else { return }

        if let location = location {
            if currentLocationMarker == nil {
                setupCurrentLocationMarker(mapView)
            } else {
                currentLocationMarker?.position = NMGLatLng(lat: location.latitude, lng: location.longitude)
            }
        } else {
            currentLocationMarker?.mapView = nil
            currentLocationMarker = nil
        }
    }

    private func createCurrentLocationIcon() -> NMFOverlayImage {
        // 현재 위치를 나타내는 아이콘 생성 (파란색 원)
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)

            // 외곽 흰색 원
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: rect)

            // 내부 파란색 원
            let innerRect = rect.insetBy(dx: 3, dy: 3)
            context.cgContext.setFillColor(UIColor.systemBlue.cgColor)
            context.cgContext.fillEllipse(in: innerRect)
        }

        return NMFOverlayImage(image: image)
    }

    private func moveMapToLocation(_ coordinate: CLLocationCoordinate2D, animated: Bool = false) {
        guard let mapView = mapView else { return }

        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoom: mapView.cameraPosition.zoom
        )

        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        if animated {
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.5
        }

        mapView.moveCamera(cameraUpdate)
    }

    private func updateSelectedCoordinate(_ position: NMGLatLng) {
        selectedCoordinate = CLLocationCoordinate2D(latitude: position.lat, longitude: position.lng)
        centerPinMarker?.position = position
    }

    private func createConfirmButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("이 위치로 설정", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }

    @objc private func confirmButtonTapped() {
        guard let coordinate = selectedCoordinate else { return }

        // TODO: 실제 역지오코딩 구현 필요
        let address = "선택된 위치의 주소"
        onLocationSelected(coordinate, address)
    }

    private func setupLayout(in containerView: UIView, mapView: NMFMapView, confirmButton: UIButton) {
        containerView.addSubview(mapView)
        containerView.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -MapConstants.mapButtonSpacing),

            confirmButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: MapConstants.horizontalPadding),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -MapConstants.horizontalPadding),
            confirmButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -MapConstants.bottomPadding),
            confirmButton.heightAnchor.constraint(equalToConstant: MapConstants.buttonHeight)
        ])
    }

    private func createErrorView() -> UIView {
        let errorView = UIView()
        errorView.backgroundColor = UIColor.systemBackground

        let label = UILabel()
        label.text = "지도를 불러올 수 없습니다.\n네이버 지도 설정을 확인해주세요."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.label
        label.translatesAutoresizingMaskIntoConstraints = false

        errorView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: errorView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: errorView.trailingAnchor, constant: -20)
        ])

        return errorView
    }
}

// MARK: - NMFMapViewCameraDelegate
extension MapCoordinator: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        updateSelectedCoordinate(mapView.cameraPosition.target)
    }
}
