//
//  StoreListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListView: View {
    @StateObject var store: StoreListStore
    @State private var visibleStoreIDs: Set<String> = []

    init(store: StoreListStore) {
        _store = StateObject(wrappedValue: store)
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
                                    print("👀 화면에 나타남: [\(index)] \(storeData.storeID) - \(storeData.name)")

                                    // 🔑 nextCursor와 일치하는지 확인
                                    checkIfMatchesNextCursor(storeData: storeData, index: index)

                                    // 현재 화면에 보이는 모든 가게 출력
                                    printCurrentlyVisible()
                                }
                            }
                            .onDisappear {
                                // 화면에서 사라질 때
                                if visibleStoreIDs.contains(storeData.storeID) {
                                    visibleStoreIDs.remove(storeData.storeID)
                                    print("👋 화면에서 사라짐: [\(index)] \(storeData.storeID) - \(storeData.name)")

                                    // 현재 화면에 보이는 모든 가게 출력
                                    printCurrentlyVisible()
                                }
                            }
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

    // 🔑 nextCursor와 일치하는 가게 확인
    private func checkIfMatchesNextCursor(storeData: StorePresentable, index: Int) {
        guard let nextCursor = store.state.nextCursor else {
            print("🚫 nextCursor가 없습니다")
            return
        }

        // nextCursor와 storeID가 일치하는지 확인
        if storeData.storeID == nextCursor {
            print("🎯 NextCursor 일치 발견!")
            print("   📍 storeID: \(storeData.storeID)")
            print("   🏪 가게명: \(storeData.name)")
            print("   📋 인덱스: [\(index)]")
            print("   🔄 nextCursor: \(nextCursor)")
            print("   ⭐ 이 가게가 다음 페이지의 시작점입니다!")
        }

        // 또는 nextCursor가 특정 패턴(예: 마지막 가게 기준)일 수도 있으니 추가 체크
        if index == store.state.filteredStores.count - 1 {
            print("🏁 마지막 가게 도달 - nextCursor 확인:")
            print("   현재 가게 ID: \(storeData.storeID)")
            print("   nextCursor: \(nextCursor)")
        }
    }

    private func printCurrentlyVisible() {
        let visibleStores = store.state.filteredStores.filter { visibleStoreIDs.contains($0.storeID) }
        print("📱 현재 화면에 보이는 가게: \(visibleStores.count)개")
        for (i, store) in visibleStores.enumerated() {
            print("   \(i+1). \(store.name) (ID: \(store.storeID))")
        }

        // 🔑 현재 nextCursor 정보도 함께 출력
        if let nextCursor = store.state.nextCursor {
            print("🔄 현재 nextCursor: \(nextCursor)")
        }
        print("---")
    }
}


struct StoreSectionHeaderView: View {
    @ObservedObject var store: StoreListStore
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.pretendardBody2)
                    .foregroundColor(.gray100)

                Spacer()

                if store.state.showSortButton {
                    Button {
                        store.send(.sortByDistance)
                    } label: {
                        HStack(spacing: 4) {
                            Text("거리순")
                                .font(.pretendardCaption1)
                                .foregroundColor(.deepSprout)
                            Image(systemName: "chart.bar.yaxis")
                                .font(.system(size: 16))
                                .foregroundColor(.deepSprout)
                        }
                    }
                }
            }

            if store.state.showFilter {
                HStack(spacing: 12) {
                    Button {
                        store.send(.togglePickchelin)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(.deepSprout)
                            Text("픽슐랭")
                                .font(.pretendardCaption2)
                                .foregroundColor(.deepSprout)
                        }
                        .opacity(store.state.isPickchelinOn ? 1.0 : 0.3)
                    }

                    Button {
                        store.send(.toggleMyPick)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(.blackSprout)
                            Text("My Pick")
                                .font(.pretendardCaption2)
                                .foregroundColor(.blackSprout)
                        }
                        .opacity(store.state.isMyPickOn ? 1.0 : 0.3)
                    }

                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    StoreListView(store: .preview)
}
