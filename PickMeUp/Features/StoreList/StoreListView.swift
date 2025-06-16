//
//  StoreListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListView: View {
    @ObservedObject var store: StoreListStore
    @State private var visibleStoreIDs: Set<String> = []

    init(store: StoreListStore) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryButton(imageName: "more", title: "전체", isSelected: store.state.selectedCategory == "전체") {
                        store.send(.selectCategory("전체"))
                    }
                    ForEach(store.state.categories, id: \.title) { category in
                        CategoryButton(imageName: category.image, title: category.title, isSelected: store.state.selectedCategory == category.title) {
                            store.send(.selectCategory(category.title))
                        }
                    }
                }
                .padding([.top, .leading, .trailing])
            }

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    StoreSectionHeaderView(
                        store: store,
                        title: "내가 픽업 가게"
                    )

                    if store.state.filteredStores.isEmpty {
                        Text("불러올 가게가 없습니다.")
                            .foregroundColor(.gray60)
                            .font(.caption)
                            .padding(.vertical, 32)
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(Array(store.state.filteredStores.enumerated()), id: \.element.storeID) { index, storeData in
                            StoreListItemView(
                                store: store,
                                storeData: storeData
                            )
                            .onAppear {
                                // 화면에 나타날 때
                                if !visibleStoreIDs.contains(storeData.storeID) {
                                    visibleStoreIDs.insert(storeData.storeID)
                                    checkIfMatchesNextCursor(storeData: storeData, index: index)
                                    checkAndLoadNextPage(currentIndex: index)
                                }
                            }
                            .onDisappear {
                                // 화면에서 사라질 때
                                if visibleStoreIDs.contains(storeData.storeID) {
                                    visibleStoreIDs.remove(storeData.storeID)
                                }
                            }
                        }

                        // 🔑 로딩 인디케이터를 최하단으로 이동
                        if store.state.isLoadingMore {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("더 많은 가게를 불러오는 중...")
                                    .font(.caption)
                                    .foregroundColor(.gray60)
                            }
                            .padding(.vertical, 16)
                        }

                        // 🔑 마지막 페이지 도달 메시지
                        if store.state.hasReachedEnd && !store.state.stores.isEmpty {
                            Text("모든 가게를 불러왔습니다.")
                                .font(.caption)
                                .foregroundColor(.gray60)
                                .padding(.vertical, 16)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.gray0)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .task {
            store.send(.onAppear)
        }
    }

    private func checkAndLoadNextPage(currentIndex: Int) {
        let totalCount = store.state.filteredStores.count

        // 마지막에서 2번째 아이템이 나타나면 다음 페이지 로드
        if currentIndex >= totalCount - 2 {

            // 다음 페이지 로드 조건 확인
            if !store.state.isLoadingMore &&
               !store.state.hasReachedEnd &&
               store.state.nextCursor != nil &&
               store.state.nextCursor != "0" {
                store.send(.loadNextPage)
            }
        }
    }

    // 🔑 nextCursor와 일치하는 가게 확인
    private func checkIfMatchesNextCursor(storeData: StorePresentable, index: Int) {
        guard let nextCursor = store.state.nextCursor else { return }
    }

    private func printCurrentlyVisible() {
        let visibleStores = store.state.filteredStores.filter { visibleStoreIDs.contains($0.storeID) }
    }
}

#Preview {
    StoreListView(store: .preview)
}
