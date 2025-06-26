//
//  StoreSearchHeaderView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/3/25.
//

import SwiftUI

struct LocationSelectionView: View {
    @State private var searchText: String = ""
    @StateObject private var locationStore: LocationSelectionStore

    init() {
        let initialState = LocationSelectionState()
        _locationStore = StateObject(wrappedValue: LocationSelectionStore(
            state: initialState,
            effect: LocationSelectionEffect(),
            reducer: LocationSelectionReducer()
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LocationRow(
                currentLocation: locationStore.state.currentLocation,
                onLocationTap: {
                    locationStore.send(.showLocationSelection)
                }
            )
            CustomSearchBar(text: $searchText)
            PopularKeywordRow()
        }
        .padding()
        .background(Color.brightSprout)
        .fullScreenCover(isPresented: Binding(
            get: { locationStore.state.isShowingLocationSheet },
            set: { _ in locationStore.send(.dismissLocationSelection) }
        )) {
            LocationManagementView(
                state: locationStore.state,
                onIntent: { intent in
                    locationStore.send(intent)
                }
            )
        }
    }
}

// MARK: - Location Row with Tap Action
private struct LocationRow: View {
    let currentLocation: String
    let onLocationTap: () -> Void

    var body: some View {
        Button(action: onLocationTap) {
            HStack(spacing: 8) {
                Image("annotation")
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(currentLocation)
                    .font(.pretendardBody1)
                    .foregroundColor(.gray90)

                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.gray90)

                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search Bar
struct CustomSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.blackSprout)

            if text.isEmpty {
                Text("검색어를 입력해주세요.")
                    .foregroundColor(.gray60)
                    .font(.pretendardBody2)
            } else {
                TextField("", text: $text)
                    .font(.pretendardBody2)
                    .foregroundColor(.gray100)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.deepSprout, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        )
    }
}

struct LocationManagementView: View {
    let state: LocationSelectionState
    let onIntent: (LocationSelectionAction.Intent) -> Void
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            searchSection
            mainContentSection
        }
        .background(Color.white)
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
            onIntent(.selectLocation(result))
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
            onIntent(.requestCurrentLocation)
        }) {
            HStack(spacing: 12) {
                if state.isLoadingCurrentLocation {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 20, height: 20)
                        .tint(.deepSprout)
                } else {
                    Image(systemName: "location.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.deepSprout)
                }

                Text(state.isLoadingCurrentLocation ? "현재 위치 찾는 중..." : "현재 위치로 주소 찾기")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blackSprout)

                Spacer()

                if !state.isLoadingCurrentLocation {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray45)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(currentLocationButtonBackground)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(state.isLoadingCurrentLocation)
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 32)
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
            ForEach(LocationDummyData.defaultLocations.filter { $0.type != .system }, id: \.id) { location in
                savedAddressRow(location)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }


    private func savedAddressRow(_ location: SavedLocation) -> some View {
        let isSelected = state.currentLocation == location.address

        return Button(action: {
            onIntent(.selectLocation(location.address))
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

#Preview {
    LocationSelectionView()
}
