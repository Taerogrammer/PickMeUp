//
//  NaverMapLocationView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/30/25.
//

import CoreLocation
import SwiftUI
import NMapsMap

struct NaverMapLocationView: UIViewRepresentable {
    let initialLocation: CLLocationCoordinate2D?
    let onLocationSelected: (CLLocationCoordinate2D, String) -> Void
    let onDismiss: () -> Void

    func makeUIView(context: Context) -> UIView {
        // 네이버 지도 SDK 초기화 상태 확인
        guard NaverMapConfiguration.shared.isReady else {
            print("❌ NaverMap not initialized properly")
            return createErrorView()
        }

        return createMapView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private func createMapView() -> UIView {
        let containerView = UIView()

        // 지도 뷰 생성
        let mapView = createNMFMapView()
        let confirmButton = createConfirmButton(for: mapView)
        let centerMarker = createCenterMarker(for: mapView)

        // 지도 카메라 델리게이트 설정
        setupCameraDelegate(for: mapView, marker: centerMarker)

        // 메모리 관리를 위한 객체 저장
        storeObjectsInContainer(containerView, mapView: mapView)

        // 레이아웃 설정
        setupLayout(in: containerView, mapView: mapView, confirmButton: confirmButton)

        return containerView
    }

    private func createNMFMapView() -> NMFMapView {
        let mapView = NMFMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false

        // 초기 위치 설정
        let coordinate = initialLocation ?? CLLocationCoordinate2D(latitude: 37.5666805, longitude: 126.9784147)
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoom: 16
        )
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))

        return mapView
    }

    private func createCenterMarker(for mapView: NMFMapView) -> NMFMarker {
        let marker = NMFMarker()
        marker.position = mapView.cameraPosition.target
        marker.mapView = mapView
        return marker
    }

    private func createConfirmButton(for mapView: NMFMapView) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("이 위치로 설정", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false

        // 버튼 액션 설정
        let target = MapButtonTarget(mapView: mapView, onLocationSelected: onLocationSelected)
        button.addTarget(target, action: #selector(MapButtonTarget.confirmLocation), for: .touchUpInside)

        return button
    }

    private func setupCameraDelegate(for mapView: NMFMapView, marker: NMFMarker) {
        let cameraDelegate = MapCameraDelegate { cameraPosition in
            marker.position = cameraPosition.target
        }
        mapView.addCameraDelegate(delegate: cameraDelegate)
    }

    private func storeObjectsInContainer(_ containerView: UIView, mapView: NMFMapView) {
        // 버튼 타겟과 카메라 델리게이트를 컨테이너에 저장하여 메모리 해제 방지
        if let button = containerView.subviews.compactMap({ $0 as? UIButton }).first,
           let target = button.allTargets.first as? MapButtonTarget {
            objc_setAssociatedObject(containerView, "buttonTarget", target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        // 카메라 델리게이트는 별도로 저장 (weak reference 방지)
        let cameraDelegate = MapCameraDelegate { _ in }
        objc_setAssociatedObject(containerView, "cameraDelegate", cameraDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func setupLayout(in containerView: UIView, mapView: NMFMapView, confirmButton: UIButton) {
        containerView.addSubview(mapView)
        containerView.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            // 맵뷰
            mapView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20),

            // 확인 버튼
            confirmButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
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

// MARK: - Map Button Target
final class MapButtonTarget: NSObject {
    private let mapView: NMFMapView
    private let onLocationSelected: (CLLocationCoordinate2D, String) -> Void

    init(mapView: NMFMapView, onLocationSelected: @escaping (CLLocationCoordinate2D, String) -> Void) {
        self.mapView = mapView
        self.onLocationSelected = onLocationSelected
        super.init()
    }

    @objc func confirmLocation() {
        let coordinate = CLLocationCoordinate2D(
            latitude: mapView.cameraPosition.target.lat,
            longitude: mapView.cameraPosition.target.lng
        )

        // TODO: 실제 역지오코딩 구현
        let address = "선택된 위치의 주소"
        onLocationSelected(coordinate, address)
    }
}

// MARK: - Map Camera Delegate
final class MapCameraDelegate: NSObject, NMFMapViewCameraDelegate {
    private let onCameraChange: (NMFCameraPosition) -> Void

    init(onCameraChange: @escaping (NMFCameraPosition) -> Void) {
        self.onCameraChange = onCameraChange
        super.init()
    }

    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        onCameraChange(mapView.cameraPosition)
    }
}
