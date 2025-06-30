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
    let currentLocation: Location
    let onLocationTap: () -> Void

    var body: some View {
        Button(action: onLocationTap) {
            HStack(spacing: 8) {
                Image("annotation")
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(currentLocation.displayName)  // displayName 사용
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

#Preview {
    LocationSelectionView()
}
