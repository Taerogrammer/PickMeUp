//
//  StoreContentSection.swift
//  PickMeUp
//
//  Created by 김태형 on 6/30/25.
//

import SwiftUI

// ✅ 스토어 컨텐츠 섹션 분리
struct StoreContentSection: View {
    @ObservedObject var store: StoreListStore
    @Binding var visibleStoreIDs: Set<String>
    let onStoreAppear: (StorePresentable, Int) -> Void

    var body: some View {
        if store.state.filteredStores.isEmpty {
            EmptyStoreView()
        } else {
            ForEach(Array(store.state.filteredStores.enumerated()), id: \.element.storeID) { index, storeData in
                StoreListItemView(
                    store: store,
                    storeData: storeData
                )
                .equatable()
                .onAppear {
                    store.send(.storeItemOnAppear(
                        storeID: storeData.storeID,
                        imagePaths: storeData.storeImageURLs
                    ))
                    onStoreAppear(storeData, index)
                }
                .onDisappear {
                    if visibleStoreIDs.contains(storeData.storeID) {
                        visibleStoreIDs.remove(storeData.storeID)
                    }
                }
            }

            LoadingAndEndViews(store: store)
        }
    }
}
