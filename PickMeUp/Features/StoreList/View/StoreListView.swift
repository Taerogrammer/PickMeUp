//
//  StoreListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListView: View {
    @StateObject var store: StoreListStore

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
                VStack(spacing: 10) {
                    StoreSectionHeaderView(
                        state: store.state,
                        send: store.send,
                        title: "내가 픽업 가게"
                    )

                    if store.state.filteredStores.isEmpty {
                        Text("불러올 가게가 없습니다.")
                            .foregroundColor(.gray60)
                            .font(.caption)
                            .padding(.vertical, 32)
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(store.state.filteredStores, id: \.storeID) { storeData in
                            StoreListItemView(
                                store: store,
                                storeData: storeData
                            )
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
}



struct StoreSectionHeaderView: View {
    let state: StoreListState
    let send: (StoreListAction.Intent) -> Void
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.pretendardBody2)
                    .foregroundColor(.gray100)

                Spacer()

                if state.showSortButton {
                    Button {
                        send(.sortByDistance)
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

            if state.showFilter {
                HStack(spacing: 12) {
                    Button {
                        send(.togglePickchelin)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(.deepSprout)
                            Text("픽슐랭")
                                .font(.pretendardCaption2)
                                .foregroundColor(.deepSprout)
                        }
                        .opacity(state.isPickchelinOn ? 1.0 : 0.3)
                    }

                    Button {
                        send(.toggleMyPick)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(.blackSprout)
                            Text("My Pick")
                                .font(.pretendardCaption2)
                                .foregroundColor(.blackSprout)
                        }
                        .opacity(state.isMyPickOn ? 1.0 : 0.3)
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

extension StoreListStore {
    static var preview: StoreListStore {
        let mockStores = StoreMockData.samples
        var mockLoadedImages: [String: [UIImage]] = [:]

        for store in mockStores {
            mockLoadedImages[store.storeID] = Array(repeating: UIImage(systemName: "photo")!, count: 3)
        }

        let state = StoreListState(
            stores: mockStores,
            loadedImages: mockLoadedImages,
            selectedCategory: "전체"
        )
        return StoreListStore(initialState: state)
    }
}
