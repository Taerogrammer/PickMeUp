//
//  NaverMapLocationView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/30/25.
//

import CoreLocation
import SwiftUI
import NMapsMap


struct NaverMapLocationView: View {
    let initialLocation: CLLocationCoordinate2D?
    let currentLocation: CLLocationCoordinate2D?
    let onLocationSelected: (CLLocationCoordinate2D, String) -> Void
    let onDismiss: () -> Void
    let onCurrentLocationRequested: (() -> Void)?

    @State private var showingAddressDetail = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedAddress: String = ""

    var body: some View {
        NaverMapRepresentable(
            initialLocation: initialLocation,
            currentLocation: currentLocation,
            onLocationConfirmed: { coordinate, address in
                // '이 위치로 설정' 버튼 클릭 시
                selectedCoordinate = coordinate
                selectedAddress = address
                showingAddressDetail = true
            },
            onDismiss: onDismiss,
            onCurrentLocationRequested: onCurrentLocationRequested
        )
        .navigationDestination(isPresented: $showingAddressDetail) {
            if let coordinate = selectedCoordinate {
                AddressDetailSetupView(
                    selectedLocation: Location(
                        id: UUID().uuidString,
                        name: nil,
                        address: selectedAddress,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude,
                        type: .custom
                    ),
                    onSave: { name, type, detail in
                        // AddressDetailSetupView에서 저장 완료 시
                        LocationManager.shared.updateSelectedLocation(
                            name: name,
                            type: type,
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude,
                            address: selectedAddress,
                            detailAddress: detail.isEmpty ? nil : detail
                        )

                        // 원래 콜백 호출 (지도 닫기 등)
                        onLocationSelected(coordinate, selectedAddress)
                    }
                )
            }
        }
    }
}
