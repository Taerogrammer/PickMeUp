//
//  LocationManagementView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/30/25.
//

import SwiftUI

struct LocationManagementView: View {
    let state: LocationSelectionState
    let onIntent: (LocationSelectionAction.Intent) -> Void

    @State private var searchText = ""
    @State private var showingNaverMap = false
    @State private var showingLocationAlert = false
    @State private var showingAddressSearch = false
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                searchSection
                mainContentSection
            }
            .background(Color.white)
            .navigationDestination(isPresented: $showingNaverMap) {
                NaverMapScreen { selectedLocation in
                    onIntent(.selectLocation(selectedLocation))
                }
            }
            .navigationDestination(isPresented: $showingAddressSearch) {
                AddressSearchView { selectedLocation in
                    onIntent(.selectLocation(selectedLocation))
                }
            }
            .onAppear {
                setupLocationManager()
            }
            .alert("위치 권한 필요", isPresented: $showingLocationAlert) {
                Button("설정으로 이동") {
                    locationManager.openAppSettings()
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("현재 위치를 사용하려면 위치 권한이 필요합니다. 설정에서 위치 권한을 허용해주세요.")
            }
        }
        .navigationBarHidden(true)
    }

    private func setupLocationManager() {
        locationManager.locationUpdateHandler = { location in
            print("위치 업데이트 완료: \(location)")
        }

        locationManager.errorHandler = { error in
            print("위치 오류: \(error)")
        }
    }

    private var headerSection: some View {
        HStack {
            Button(action: {
                onIntent(.dismissLocationSelection)
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blackSprout)
            }

            Spacer()

            Text("주소 관리")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blackSprout)

            Spacer()

            Button(action: {}) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.clear)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.brightSprout)
    }

    private var searchSection: some View {
        VStack(spacing: 0) {
            Button(action: {
                showingAddressSearch = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.deepSprout)

                    Text("도로명, 건물명 또는 지번으로 검색")
                        .font(.system(size: 16))
                        .foregroundColor(.gray60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.deepSprout.opacity(0.3), lineWidth: 1.5)
                )
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(Color.brightSprout)
    }

    private var mainContentSection: some View {
        VStack(spacing: 0) {
            currentLocationButton
            savedAddressesSection
            errorMessageSection
            Spacer()
        }
        .background(Color.white)
    }

    private var currentLocationButton: some View {
        Button(action: {
            handleCurrentLocationTap()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.deepSprout)

                Text("현재 위치로 주소 찾기")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blackSprout)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray45)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(currentLocationButtonBackground)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 16) // ✅ 간격 조정
    }

    private func handleCurrentLocationTap() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestLocationPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            showingNaverMap = true
        case .denied, .restricted:
            showingLocationAlert = true
        @unknown default:
            break
        }
    }

    private var currentLocationButtonBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.brightSprout.opacity(0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.deepSprout.opacity(0.3), lineWidth: 1)
            )
    }

    private var savedAddressesSection: some View {
        VStack(spacing: 12) {
            ForEach(LocationDummyData.defaultLocations, id: \.id) { location in
                savedAddressRow(location)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func savedAddressRow(_ location: Location) -> some View {
        let isSelected = state.currentLocation == location

        return Button(action: {
            onIntent(.selectLocation(location))
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.deepSprout : Color.deepSprout.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: location.icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .white : .deepSprout)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(location.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blackSprout)

                    Text(location.address)
                        .font(.system(size: 14))
                        .foregroundColor(.gray45)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepSprout)
                } else {
                    Button(action: {
                        onIntent(.editAddress(location.address))
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(.gray45)
                            .padding(8)
                            .background(Circle().fill(Color.gray15))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(savedAddressRowBackground(isSelected: isSelected))
    }

    private func savedAddressRowBackground(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.deepSprout.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.deepSprout, lineWidth: 2)
                )
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray30.opacity(0.3), lineWidth: 1)
                )
        }
    }

    private var errorMessageSection: some View {
        Group {
            if let errorMessage = state.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.brightForsythia)

                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.blackSprout)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(errorMessageBackground)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private var errorMessageBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.brightForsythia.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.brightForsythia.opacity(0.3), lineWidth: 1)
            )
    }
}
