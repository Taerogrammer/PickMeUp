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
        let containerView = UIView()

        // 네이버 지도 SDK 초기화 상태 확인
        guard let clientId = NMFAuthManager.shared().ncpKeyId, !clientId.isEmpty else {
            print("❌ NaverMap not initialized. Please check your App initialization.")
            return createErrorView()
        }

        // 네이버 맵 설정
        let mapView = NMFMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false

        // 초기 위치 설정
        let coordinate = initialLocation ?? CLLocationCoordinate2D(latitude: 37.5666805, longitude: 126.9784147)
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoom: 16
        )
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))

        // 지도 중앙에 마커 표시
        let centerMarker = NMFMarker()
        centerMarker.position = mapView.cameraPosition.target
        centerMarker.mapView = mapView

        // 하단 확인 버튼
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("이 위치로 설정", for: .normal)
        confirmButton.backgroundColor = UIColor.systemBlue
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 12
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        // 버튼 액션을 위한 target 설정
        let target = MapButtonTarget(mapView: mapView, onLocationSelected: onLocationSelected)
        confirmButton.addTarget(target, action: #selector(MapButtonTarget.confirmLocation), for: .touchUpInside)

        // target과 delegate를 containerView에 저장하여 메모리에서 해제되지 않도록 함
        let cameraDelegate = MapCameraDelegate { cameraPosition in
            centerMarker.position = cameraPosition.target
        }
        mapView.addCameraDelegate(delegate: cameraDelegate)

        objc_setAssociatedObject(containerView, "buttonTarget", target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(containerView, "cameraDelegate", cameraDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 레이아웃 설정
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

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    // 오류 발생 시 표시할 뷰
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

class MapButtonTarget: NSObject {
    let mapView: NMFMapView
    let onLocationSelected: (CLLocationCoordinate2D, String) -> Void

    init(mapView: NMFMapView, onLocationSelected: @escaping (CLLocationCoordinate2D, String) -> Void) {
        self.mapView = mapView
        self.onLocationSelected = onLocationSelected
    }

    @objc func confirmLocation() {
        let coordinate = CLLocationCoordinate2D(
            latitude: mapView.cameraPosition.target.lat,
            longitude: mapView.cameraPosition.target.lng
        )

        // 역지오코딩으로 주소 가져오기 (여기서는 더미)
        let address = "선택된 위치의 주소"
        onLocationSelected(coordinate, address)
    }
}

class MapCameraDelegate: NSObject, NMFMapViewCameraDelegate {
    let onCameraChange: (NMFCameraPosition) -> Void

    init(onCameraChange: @escaping (NMFCameraPosition) -> Void) {
        self.onCameraChange = onCameraChange
    }

    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        onCameraChange(mapView.cameraPosition)
    }
}
