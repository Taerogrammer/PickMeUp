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

// MARK: - Location Management Sheet
struct LocationManagementView: View {
    let state: LocationSelectionState
    let onIntent: (LocationSelectionAction.Intent) -> Void
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            HStack {
                Button(action: {
                    onIntent(.dismissLocationSelection)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }

                Spacer()

                Text("주소 관리")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)

                Spacer()

                // 오른쪽 공간 맞추기용 투명 버튼
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.clear)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            // 검색창
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)

                TextField("도로명, 건물명 또는 지번으로 검색", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .onSubmit {
                        if !searchText.isEmpty {
                            onIntent(.searchAddress(searchText))
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            // 검색 결과 표시
            if state.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("검색 중...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding()
            } else if !state.searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(state.searchResults, id: \.self) { result in
                            Button(action: {
                                onIntent(.selectLocation(result))
                            }) {
                                HStack {
                                    Text(result)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding()
                            }
                            .buttonStyle(PlainButtonStyle())

                            if result != state.searchResults.last {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // 현재 위치로 주소 찾기 버튼
            Button(action: {
                onIntent(.requestCurrentLocation)
            }) {
                HStack(spacing: 12) {
                    if state.isLoadingCurrentLocation {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }

                    Text(state.isLoadingCurrentLocation ? "현재 위치 찾는 중..." : "현재 위치로 주소 찾기")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(state.isLoadingCurrentLocation)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // 집 섹션
            if let homeAddress = state.savedAddresses.first {
                VStack(alignment: .leading, spacing: 16) {
                    Button(action: {
                        onIntent(.selectLocation(homeAddress))
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("집")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)

                                Text(homeAddress)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Button(action: {
                                onIntent(.editAddress(homeAddress))
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemBlue).opacity(0.1))
                }
            }

            // 회사 추가 버튼
            Button(action: {
                onIntent(.addNewAddress)
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)

                    Text("회사 추가")
                        .font(.system(size: 16))
                        .foregroundColor(.black)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())

            // 에러 메시지 표시
            if let errorMessage = state.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .background(Color.white)
    }
}

#Preview {
    LocationSelectionView()
}
