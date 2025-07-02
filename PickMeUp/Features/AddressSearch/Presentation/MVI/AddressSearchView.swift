//
//  AddressSearchView.swift
//  PickMeUp
//
//  Created by 김태형 on 7/1/25.
//

import SwiftUI

// MARK: - 주소 검색 전용 화면
struct AddressSearchView: View {
    @StateObject private var searchStore: AddressSearchStore
    @State private var searchText = ""
    @State private var showingDetailSetup = false
    @State private var selectedLocationForDetail: Location?
    @Environment(\.dismiss) private var dismiss

    let onAddressSelected: (Location) -> Void

    init(onAddressSelected: @escaping (Location) -> Void) {
        self.onAddressSelected = onAddressSelected
        let initialState = AddressSearchState()
        _searchStore = StateObject(wrappedValue: AddressSearchStore(
            state: initialState,
            effect: AddressSearchEffect(),
            reducer: AddressSearchReducer()
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                searchInputSection
                searchResultsSection
                Spacer()
            }
            .sheet(isPresented: $showingDetailSetup) {
                if let location = selectedLocationForDetail {
                    AddressDetailSetupView(
                        selectedLocation: location,
                        onSave: { name, type, detail in
                            print("저장됨:")
                            print("- 이름: \(name)")
                            print("- 타입: \(type.displayName)")
                            print("- 상세주소: \(detail)")

                            // 원래 콜백 호출 (지도에 표시 등)
                            onAddressSelected(location)
                        }
                    )
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }

    private var headerSection: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blackSprout)
            }

            Text("주소 검색")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blackSprout)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.brightSprout)
    }

    private var searchInputSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(.deepSprout)

                TextField("도로명, 건물명 또는 지번으로 검색", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.blackSprout)
                    .onSubmit {
                        performSearch()
                    }

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchStore.send(.clearResults)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray45)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(searchText.isEmpty ? Color.deepSprout.opacity(0.3) : Color.deepSprout, lineWidth: 1.5)
            )
            .cornerRadius(12)

            Button(action: performSearch) {
                Text("검색")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(searchText.isEmpty ? Color.gray45 : Color.deepSprout)
                    .cornerRadius(12)
            }
            .disabled(searchText.isEmpty || searchStore.state.isLoading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.brightSprout)
    }

    private var searchResultsSection: some View {
        Group {
            if searchStore.state.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.deepSprout)

                    Text("검색 중...")
                        .font(.system(size: 16))
                        .foregroundColor(.gray45)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)

            } else if !searchStore.state.searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchStore.state.searchResults, id: \.id) { location in
                            NavigationLink(destination:
                                AddressDetailSetupView(
                                    selectedLocation: location,
                                    onSave: { name, type, detail in
                                        print("📍 저장된 주소 정보:")
                                        print("- 이름: \(name)")
                                        print("- 타입: \(type.displayName)")
                                        print("- 상세주소: \(detail)")
                                        print("- 위도: \(location.latitude)")
                                        print("- 경도: \(location.longitude)")
                                        print("- 전체주소: \(location.address)")

                                        // 원래 콜백 호출 (지도에 표시 등)
                                        onAddressSelected(location)
                                    }
                                )
                            ) {
                                AddressResultRowContent(location: location)
                            }
                            .buttonStyle(PlainButtonStyle())

                            if location.id != searchStore.state.searchResults.last?.id {
                                Divider()
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.top, 8)

            } else if searchStore.state.hasSearched && searchStore.state.searchResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.gray45)

                    Text("검색 결과가 없습니다")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blackSprout)

                    Text("다른 검색어로 다시 시도해보세요")
                        .font(.system(size: 14))
                        .foregroundColor(.gray45)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)

            } else {
                VStack(spacing: 20) {
                    Image(systemName: "location.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.gray30)

                    VStack(spacing: 8) {
                        Text("주소를 검색해보세요")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blackSprout)

                        Text("건물명, 업체명, 도로명으로 검색 가능합니다")
                            .font(.system(size: 14))
                            .foregroundColor(.gray45)
                    }

                    // 검색 예시
                    VStack(alignment: .leading, spacing: 8) {
                        Text("검색 예시")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray60)

                        VStack(alignment: .leading, spacing: 4) {
                            searchExampleRow("강남역")
                            searchExampleRow("롯데월드타워")
                            searchExampleRow("서울특별시 강남구 테헤란로 427")
                            searchExampleRow("코엑스")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.gray15)
                    .cornerRadius(12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 40)
            }

            if let errorMessage = searchStore.state.errorMessage {
                ErrorMessageView(message: errorMessage) {
                    searchStore.send(.clearError)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private func searchExampleRow(_ text: String) -> some View {
        Button(action: {
            searchText = text
            performSearch()
        }) {
            HStack {
                Text(text)
                    .font(.system(size: 13))
                    .foregroundColor(.gray60)

                Spacer()

                Image(systemName: "arrow.up.left")
                    .font(.system(size: 10))
                    .foregroundColor(.gray45)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func performSearch() {
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searchStore.send(.searchAddress(searchText.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
    }
}
