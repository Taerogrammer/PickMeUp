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
                                        print("저장됨:")
                                        print("- 이름: \(name)")
                                        print("- 타입: \(type.displayName)")
                                        print("- 상세주소: \(detail)")

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

// MARK: - 검색 결과 행 (NavigationLink용)
struct AddressResultRowContent: View {
    let location: Location

    var body: some View {
        HStack(spacing: 16) {
            // 위치 아이콘
            ZStack {
                Circle()
                    .fill(Color.deepSprout.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.deepSprout)
            }

            VStack(alignment: .leading, spacing: 6) {
                // 주요 주소
                Text(location.address)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blackSprout)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                // 건물명
                if let name = location.name, !name.isEmpty {
                    Text(name)
                        .font(.system(size: 14))
                        .foregroundColor(.gray60)
                        .lineLimit(1)
                }

                // 좌표 정보
                Text("위도: \(String(format: "%.6f", location.latitude)), 경도: \(String(format: "%.6f", location.longitude))")
                    .font(.system(size: 12))
                    .foregroundColor(.gray45)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray45)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - 검색 결과 행
struct AddressResultRow: View {
    let location: Location
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 위치 아이콘
                ZStack {
                    Circle()
                        .fill(Color.deepSprout.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.deepSprout)
                }

                VStack(alignment: .leading, spacing: 6) {
                    // 주요 주소 (도로명 주소 우선)
                    Text(location.address)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blackSprout)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    // 부가 정보 (건물명이 있다면 표시)
                    if let name = location.name, !name.isEmpty {
                        Text(name)
                            .font(.system(size: 14))
                            .foregroundColor(.gray60)
                            .lineLimit(1)
                    }

                    // 좌표 정보 (작은 글씨로)
                    Text("위도: \(String(format: "%.6f", location.latitude)), 경도: \(String(format: "%.6f", location.longitude))")
                        .font(.system(size: 12))
                        .foregroundColor(.gray45)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray45)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 에러 메시지 뷰
struct ErrorMessageView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundColor(.brightForsythia)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.blackSprout)
                .multilineTextAlignment(.leading)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(.gray45)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.brightForsythia.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.brightForsythia.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - 주소 검색 상태 관리
struct AddressSearchState {
    var searchResults: [Location] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var hasSearched: Bool = false
}

enum AddressSearchAction {
    enum Intent {
        case searchAddress(String)
        case clearResults
        case clearError
    }

    enum Result {
        case searchStarted
        case searchSucceeded([Location])
        case searchFailed(String)
        case resultsCleared
        case errorCleared
    }
}

struct AddressSearchEffect {
    func handle(_ intent: AddressSearchAction.Intent, store: AddressSearchStore) {
        switch intent {
        case .searchAddress(let query):
            Task {
                await searchAddressFromNaverAPI(query: query, store: store)
            }
        case .clearResults:
            Task { @MainActor in
                store.send(.resultsCleared)
            }
        case .clearError:
            Task { @MainActor in
                store.send(.errorCleared)
            }
        }
    }

    // 네이버 지오코딩 API 호출
    private func searchAddressFromNaverAPI(query: String, store: AddressSearchStore) async {
        await MainActor.run {
            store.send(.searchStarted)
        }

        do {
            let results = try await NaverGeocodingService.shared.searchAddress(query: query)

            await MainActor.run {
                if results.isEmpty {
                    store.send(.searchFailed("검색 결과를 찾을 수 없습니다."))
                } else {
                    store.send(.searchSucceeded(results))
                }
            }
        } catch let error as NaverGeocodingError {
            await MainActor.run {
                store.send(.searchFailed(error.localizedDescription))
            }
        } catch {
            await MainActor.run {
                store.send(.searchFailed("네트워크 오류가 발생했습니다. 다시 시도해주세요."))
            }
        }
    }
}

struct AddressSearchReducer {
    func reduce(state: inout AddressSearchState, intent: AddressSearchAction.Intent) {
        switch intent {
        case .searchAddress:
            state.isLoading = true
            state.errorMessage = nil

        case .clearResults:
            state.searchResults = []
            state.hasSearched = false
            state.errorMessage = nil

        case .clearError:
            state.errorMessage = nil
        }
    }

    func reduce(state: inout AddressSearchState, result: AddressSearchAction.Result) {
        switch result {
        case .searchStarted:
            state.isLoading = true
            state.errorMessage = nil

        case .searchSucceeded(let results):
            state.searchResults = results
            state.isLoading = false
            state.hasSearched = true

        case .searchFailed(let error):
            state.errorMessage = error
            state.isLoading = false
            state.hasSearched = true

        case .resultsCleared:
            state.searchResults = []
            state.hasSearched = false
            state.errorMessage = nil

        case .errorCleared:
            state.errorMessage = nil
        }
    }
}

final class AddressSearchStore: ObservableObject {
    @Published private(set) var state: AddressSearchState
    private let effect: AddressSearchEffect
    private let reducer: AddressSearchReducer

    init(state: AddressSearchState, effect: AddressSearchEffect, reducer: AddressSearchReducer) {
        self.state = state
        self.effect = effect
        self.reducer = reducer
    }

    @MainActor
    func send(_ action: AddressSearchAction.Intent) {
        reducer.reduce(state: &state, intent: action)
        effect.handle(action, store: self)
    }

    @MainActor
    func send(_ result: AddressSearchAction.Result) {
        reducer.reduce(state: &state, result: result)
    }
}
