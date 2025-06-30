//
//  NaverMapScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 6/30/25.
//

import CoreLocation
import SwiftUI

struct NaverMapScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()

    let onLocationSelected: (Location) -> Void

    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedAddress: String = ""

    var body: some View {
        ZStack {
            mapView
            topNavigationBar
            currentLocationButton
            currentLocationInfo
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupLocationManager()
        }
    }

    private var mapView: some View {
        NaverMapLocationView(
            initialLocation: locationManager.currentLocation?.coordinate,
            onLocationSelected: handleLocationSelection,
            onDismiss: { dismiss() }
        )
        .ignoresSafeArea()
    }

    private var topNavigationBar: some View {
        VStack {
            HStack {
                navigationButton(title: "취소", action: { dismiss() })
                Spacer()
                navigationTitle
                Spacer()
                // 대칭을 위한 투명 버튼
                navigationButton(title: "", action: {})
                    .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60) // Safe area 고려

            Spacer()
        }
    }

    private var navigationTitle: some View {
        Text("위치 선택")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.blackSprout)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
    }

    private func navigationButton(title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.system(size: 16))
            .foregroundColor(.blackSprout)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
    }

    private var currentLocationButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    locationManager.requestLocationPermission()
                }) {
                    Image(systemName: locationManager.isLoading ? "arrow.clockwise" : "location.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.deepSprout)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                        .rotationEffect(.degrees(locationManager.isLoading ? 360 : 0))
                        .animation(
                            locationManager.isLoading ?
                                .linear(duration: 1).repeatForever(autoreverses: false) :
                                .default,
                            value: locationManager.isLoading
                        )
                }
                .padding(.trailing, 20)
                .padding(.bottom, 120)
            }
        }
    }

    @ViewBuilder
    private var currentLocationInfo: some View {
        if let location = locationManager.currentLocation {
            VStack {
                locationInfoCard(for: location)
                    .padding(.top, 120)
                Spacer()
            }
        }
    }

    private func locationInfoCard(for location: CLLocation) -> some View {
        VStack(spacing: 8) {
            Text("현재 위치")
                .font(.caption)
                .foregroundColor(.gray)

            Text("위도: \(location.coordinate.latitude, specifier: "%.6f")")
                .font(.caption2)
                .foregroundColor(.blackSprout)

            Text("경도: \(location.coordinate.longitude, specifier: "%.6f")")
                .font(.caption2)
                .foregroundColor(.blackSprout)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 2)
    }

    // MARK: - Private Methods

    private func setupLocationManager() {
        locationManager.locationUpdateHandler = { location in
            // 필요한 경우 지도 중심을 현재 위치로 이동하는 로직 추가
        }

        locationManager.errorHandler = { error in
            print("Location error: \(error)")
        }
    }

    private func handleLocationSelection(coordinate: CLLocationCoordinate2D, address: String) {
        selectedCoordinate = coordinate
        selectedAddress = address
        confirmLocationSelection()
    }

    private func confirmLocationSelection() {
        guard let coordinate = selectedCoordinate else {
            dismiss()
            return
        }

        let location = Location(
            id: UUID().uuidString,
            name: nil,
            address: selectedAddress.isEmpty ? "선택된 위치" : selectedAddress,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            type: .custom
        )

        onLocationSelected(location)
        dismiss()
    }
}
