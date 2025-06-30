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
            currentLocationButton // ✅ 갈색 현재 위치 버튼 추가됨
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
            currentLocation: locationManager.currentLocation?.coordinate,
            onLocationSelected: handleLocationSelection,
            onDismiss: { dismiss() },
            onCurrentLocationRequested: {
                locationManager.requestLocationPermission()
            }
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
                navigationButton(title: "", action: {})
                    .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)

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

    // ✅ 현재 위치 버튼 - 새로 추가된 코드
    private var currentLocationButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    print("🔘 현재 위치 버튼 클릭됨!")
                    locationManager.requestLocationPermission()
                }) {
                    Image(systemName: locationManager.isLoading ? "arrow.clockwise" : "location.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56) // 조금 더 크게
                        .background(Color(red: 0.8, green: 0.6, blue: 0.4)) // 갈색 톤
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        .rotationEffect(.degrees(locationManager.isLoading ? 360 : 0))
                        .animation(
                            locationManager.isLoading ?
                                .linear(duration: 1).repeatForever(autoreverses: false) :
                                .default,
                            value: locationManager.isLoading
                        )
                }
                .padding(.trailing, 20)
                .padding(.bottom, 160) // 주소 카드와 겹치지 않게 조정
            }
        }
    }

    @ViewBuilder
    private var currentLocationInfo: some View {
        if let location = locationManager.currentLocation {
            VStack {
                HStack {
                    locationInfoCard(for: location)
                    Spacer()
                    if let selectedCoord = selectedCoordinate {
                        addressLocationCard(for: selectedCoord)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 120)
                Spacer()
            }
        }
    }

    private func locationInfoCard(for location: CLLocation) -> some View {
        VStack(spacing: 4) {
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                Text("현재 위치")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Text("\(location.coordinate.latitude, specifier: "%.4f"), \(location.coordinate.longitude, specifier: "%.4f")")
                .font(.caption2)
                .foregroundColor(.blackSprout)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.9))
        .cornerRadius(6)
        .shadow(radius: 1)
    }

    private func addressLocationCard(for coordinate: CLLocationCoordinate2D) -> some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "mappin")
                    .foregroundColor(.blue)
                    .font(.system(size: 8))
                Text("배달위치")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Text("\(coordinate.latitude, specifier: "%.4f"), \(coordinate.longitude, specifier: "%.4f")")
                .font(.caption2)
                .foregroundColor(.blackSprout)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.9))
        .cornerRadius(6)
        .shadow(radius: 1)
    }

    private func setupLocationManager() {
        locationManager.locationUpdateHandler = { location in
            print("Current location updated: \(location)")
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
