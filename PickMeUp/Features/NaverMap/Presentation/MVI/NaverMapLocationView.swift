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
                        LocationManager.shared.updateSelectedLocation(
                            name: name,
                            type: type,
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude,
                            address: selectedAddress,
                            detailAddress: detail.isEmpty ? nil : detail
                        )

                        onLocationSelected(coordinate, selectedAddress)
                    }
                )
            }
        }
    }
}
