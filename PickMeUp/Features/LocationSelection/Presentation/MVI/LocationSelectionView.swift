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

#Preview {
    LocationSelectionView()
}
