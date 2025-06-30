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
            // 네이버 지도
            NaverMapLocationView(
                initialLocation: locationManager.currentLocation?.coordinate,
                onLocationSelected: { coordinate, address in
                    selectedCoordinate = coordinate
                    selectedAddress = address
                    confirmLocationSelection()
                },
                onDismiss: {
                    dismiss()
                }
            )
            .ignoresSafeArea()

            // 상단 네비게이션 바
            VStack {
                HStack {
                    Button("취소") {
                        dismiss()
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.blackSprout)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)

                    Spacer()

                    Text("위치 선택")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blackSprout)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)

                    Spacer()

                    // 빈 공간 (대칭을 위해)
                    Color.clear
                        .frame(width: 60, height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60) // Safe area 고려

                Spacer()
            }

            // 현재 위치 버튼
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
                            .animation(locationManager.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: locationManager.isLoading)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 120) // 하단 버튼 공간 확보
                }
            }

            // 위치 정보 표시 (상단)
            if let location = locationManager.currentLocation {
                VStack {
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
                    .padding(.top, 120)

                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupLocationManager()
        }
    }

    private func setupLocationManager() {
        // 현재 위치 업데이트 시 지도 중심 이동 (필요시)
        locationManager.locationUpdateHandler = { location in
            // 필요한 경우 지도 중심을 현재 위치로 이동하는 로직 추가
        }

        // 오류 처리
        locationManager.errorHandler = { error in
            print("Location error: \(error)")
        }
    }

    private func confirmLocationSelection() {
        guard let coordinate = selectedCoordinate else {
            dismiss()
            return
        }

        // 선택된 좌표로 Location 객체 생성
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
