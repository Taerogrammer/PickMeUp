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
                    // 지도에서 선택된 위치 처리
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
        // 위치 업데이트 성공해도 지도는 열지 않음 (단순 로그만)
        locationManager.locationUpdateHandler = { location in
            print("위치 업데이트 완료: \(location)")
        }

        // 오류 발생 시 알림 표시
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
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(.deepSprout)

                TextField("도로명, 건물명 또는 지번으로 검색", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.blackSprout)
                    .onSubmit {
                        if !searchText.isEmpty {
                            onIntent(.searchAddress(searchText))
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.deepSprout.opacity(0.3), lineWidth: 1.5)
            )
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(Color.brightSprout)
    }

    private var mainContentSection: some View {
        VStack(spacing: 0) {
            searchResultsSection
            currentLocationButton
            savedAddressesSection
            errorMessageSection
            Spacer()
        }
        .background(Color.white)
    }

    private var searchResultsSection: some View {
        Group {
            if state.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.deepSprout)
                    Text("검색 중...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray45)
                }
                .padding(.vertical, 32)
            } else if !state.searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(state.searchResults, id: \.self) { result in
                            searchResultRow(result)

                            if result != state.searchResults.last {
                                Divider()
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private func searchResultRow(_ result: String) -> some View {
        Button(action: {
            if let location = LocationDummyData.searchResultLocations.first(where: { $0.address == result }) {
                onIntent(.selectLocation(location))
            }
        }) {
            HStack {
                Circle()
                    .fill(Color.deepSprout.opacity(0.2))
                    .frame(width: 8, height: 8)

                Text(result)
                    .font(.system(size: 16))
                    .foregroundColor(.blackSprout)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(.gray45)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
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
        .padding(.bottom, 32)
    }

    private func handleCurrentLocationTap() {
        // 단순히 권한 체크만 하고 지도는 절대 자동으로 열지 않음
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // 권한 요청
            locationManager.requestLocationPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            // 권한이 있으면 지도 열기
            showingNaverMap = true
        case .denied, .restricted:
            // 권한 거부 시 알림
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
