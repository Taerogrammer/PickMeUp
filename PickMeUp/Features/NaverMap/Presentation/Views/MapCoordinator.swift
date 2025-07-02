//
//  MapCoordinaTor.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import CoreLocation
import Foundation
import NMapsMap

final class MapCoordinator: NSObject {
    private let initialLocation: CLLocationCoordinate2D?
    private var currentLocation: CLLocationCoordinate2D?
    private let onLocationConfirmed: (CLLocationCoordinate2D, String) -> Void
    private let onDismiss: () -> Void
    private let onCurrentLocationRequested: (() -> Void)?

    // Map components
    private var mapView: NMFMapView?
    private var currentLocationMarker: NMFMarker?
    private var centerPinMarker: NMFMarker?
    private var selectedCoordinate: CLLocationCoordinate2D?
    private var selectedAddress: String = ""
    private var geocodingTimer: Timer?

    // UI components
    private var addressLabel: UILabel?
    private var loadingIndicator: UIActivityIndicatorView?

    init(
        initialLocation: CLLocationCoordinate2D?,
        currentLocation: CLLocationCoordinate2D?,
        onLocationConfirmed: @escaping (CLLocationCoordinate2D, String) -> Void,
        onDismiss: @escaping () -> Void,
        onCurrentLocationRequested: (() -> Void)? = nil
    ) {
        self.initialLocation = initialLocation
        self.currentLocation = currentLocation
        self.onLocationConfirmed = onLocationConfirmed
        self.onDismiss = onDismiss
        self.onCurrentLocationRequested = onCurrentLocationRequested
        super.init()
    }

    // MARK: - 기존 메서드들 (변경 없음)
    func createMapContainer() -> UIView {
        guard NaverMapConfiguration.shared.isReady else {
            print("❌ NaverMap not initialized properly")
            return createErrorView()
        }

        let containerView = UIView()
        let mapView = createMapView()
        let addressCard = createAddressCard()

        containerView.addSubview(mapView)
        containerView.addSubview(addressCard)

        setupConstraints(containerView: containerView, mapView: mapView, addressCard: addressCard)
        setupMapComponents(mapView)

        self.mapView = mapView
        return containerView
    }

    func updateCurrentLocation(_ newLocation: CLLocationCoordinate2D?) {
        guard let mapView = mapView else { return }

        self.currentLocation = newLocation
        updateCurrentLocationMarker(newLocation)

        if let location = newLocation {
            moveMapToLocation(location, animated: true)
        }
    }

    private func createMapView() -> NMFMapView {
        let mapView = NMFMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false

        let coordinate = currentLocation ?? initialLocation ?? MapConstants.seoulCoordinate
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoom: MapConstants.defaultZoom
        )
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))

        return mapView
    }

    private func setupMapComponents(_ mapView: NMFMapView) {
        mapView.addCameraDelegate(delegate: self)
        setupCenterPinMarker(mapView)
        setupCurrentLocationMarker(mapView)
        updateSelectedCoordinate(mapView.cameraPosition.target)
    }

    private func setupCenterPinMarker(_ mapView: NMFMapView) {
        let marker = NMFMarker()
        marker.position = mapView.cameraPosition.target
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
        marker.mapView = mapView
        self.centerPinMarker = marker
    }

    private func setupCurrentLocationMarker(_ mapView: NMFMapView) {
        guard let currentLocation = currentLocation else { return }

        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: currentLocation.latitude, lng: currentLocation.longitude)
        marker.iconImage = createCurrentLocationIcon()
        marker.anchor = CGPoint(x: 0.5, y: 0.5)
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
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)

            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: rect)

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

        geocodingTimer?.invalidate()
        showAddressLoading()

        geocodingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: position.lat, longitude: position.lng))
        }
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Geocoding error: \(error.localizedDescription)")
                    self?.selectedAddress = "주소를 가져올 수 없습니다"
                    self?.updateAddressUI()
                    return
                }

                guard let placemark = placemarks?.first else {
                    self?.selectedAddress = "주소를 찾을 수 없습니다"
                    self?.updateAddressUI()
                    return
                }

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

                let fullAddress = addressComponents.joined(separator: " ")
                self?.selectedAddress = fullAddress.isEmpty ? "알 수 없는 위치" : fullAddress
                self?.updateAddressUI()
            }
        }
    }

    private func createAddressCard() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.systemBackground
        cardView.layer.cornerRadius = 20
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: -2)
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOpacity = 0.1
        cardView.translatesAutoresizingMaskIntoConstraints = false

        let handleBar = UIView()
        handleBar.backgroundColor = UIColor.systemGray4
        handleBar.layer.cornerRadius = 2
        handleBar.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "location.fill")
        iconImageView.tintColor = UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "배달 위치"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = UIColor.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let addressLabel = UILabel()
        addressLabel.text = "지도를 움직여서 배달 위치를 선택해주세요"
        addressLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addressLabel.textColor = UIColor.secondaryLabel
        addressLabel.numberOfLines = 0
        addressLabel.translatesAutoresizingMaskIntoConstraints = false

        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.color = UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        let detailButton = UIButton(type: .system)
        detailButton.setTitle("상세 주소 입력", for: .normal)
        detailButton.setTitleColor(UIColor(.deepSprout), for: .normal)
        detailButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        detailButton.contentHorizontalAlignment = .leading
        detailButton.translatesAutoresizingMaskIntoConstraints = false

        // ✅ 버튼은 기존과 동일하게 유지
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("이 위치로 설정", for: .normal)
        confirmButton.backgroundColor = UIColor(.deepSprout)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 12
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)

        cardView.addSubview(handleBar)
        cardView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(addressLabel)
        cardView.addSubview(loadingIndicator)
        cardView.addSubview(detailButton)
        cardView.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            handleBar.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            handleBar.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 40),
            handleBar.heightAnchor.constraint(equalToConstant: 4),

            iconImageView.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 20),
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),

            loadingIndicator.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            addressLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            detailButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 8),
            detailButton.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),

            confirmButton.topAnchor.constraint(equalTo: detailButton.bottomAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            confirmButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])

        self.addressLabel = addressLabel
        self.loadingIndicator = loadingIndicator

        return cardView
    }

    private func updateAddressUI() {
        loadingIndicator?.stopAnimating()
        addressLabel?.text = selectedAddress
    }

    private func showAddressLoading() {
        loadingIndicator?.startAnimating()
        addressLabel?.text = "주소를 찾고 있어요..."
    }

    // ✅ 핵심: 여기서 AddressDetailSetupView로 이동
    @objc private func confirmButtonTapped() {
        guard let coordinate = selectedCoordinate else { return }
        geocodingTimer?.invalidate()

        print("🗺️ 지도에서 위치 선택:")
        print("   - 좌표: \(coordinate)")
        print("   - 주소: \(selectedAddress)")

        // AddressDetailSetupView로 이동하기 위해 콜백 호출
        onLocationConfirmed(coordinate, selectedAddress)
    }

    private func setupConstraints(containerView: UIView, mapView: NMFMapView, addressCard: UIView) {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            addressCard.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            addressCard.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            addressCard.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
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
