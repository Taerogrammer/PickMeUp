//
//  StoreListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListView: View {
    @StateObject private var store = StoreListStore()

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
                        title: "내가 픽업 가게",
                        showFilter: true,
                        showSortButton: true,
                        onSortTapped: {},
                        onPickchelinToggle: { store.send(.togglePickchelin) },
                        onMyPickToggle: { store.send(.toggleMyPick) },
                        isPickchelinOn: store.state.isPickchelinOn,
                        isMyPickOn: store.state.isMyPickOn
                    )

                    if store.state.filteredStores.isEmpty {
                        Text("불러올 가게가 없습니다.")
                            .foregroundColor(.gray60)
                            .font(.caption)
                            .padding(.vertical, 32)
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(Array(store.state.filteredStores.enumerated()), id: \.element.storeID) { _, store in
                            StoreListItemView(store: store)
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

#Preview {
    StoreListView()
}

struct StoreSectionView: View {
    let title: String
    let stores: [StorePresentable]
    let showFilter: Bool
    let showSortButton: Bool
    let onSortTapped: (() -> Void)?
    let onPickchelinToggle: (() -> Void)?
    let onMyPickToggle: (() -> Void)?
    let isPickchelinOn: Bool
    let isMyPickOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StoreSectionHeaderView(
                title: title,
                showFilter: showFilter,
                showSortButton: showSortButton,
                onSortTapped: onSortTapped,
                onPickchelinToggle: onPickchelinToggle,
                onMyPickToggle: onMyPickToggle,
                isPickchelinOn: isPickchelinOn,
                isMyPickOn: isMyPickOn
            )

            VStack(spacing: 10) {
                ForEach(stores, id: \.storeID) { store in
                    StoreListItemView(store: store)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct StoreSectionHeaderView: View {
    var title: String
    var showFilter: Bool = true
    var showSortButton: Bool = true

    var onSortTapped: (() -> Void)? = nil
    var onPickchelinToggle: (() -> Void)? = nil
    var onMyPickToggle: (() -> Void)? = nil

    var isPickchelinOn: Bool = true
    var isMyPickOn: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.pretendardBody2)
                    .foregroundColor(.gray100)

                Spacer()

                if showSortButton {
                    Button(action: {
                        onSortTapped?()
                    }) {
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

            if showFilter {
                HStack(spacing: 12) {
                    // 픽슐랭
                    Button(action: { onPickchelinToggle?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(.deepSprout)
                            Text("픽슐랭")
                                .font(.pretendardCaption2)
                                .foregroundColor(.deepSprout)
                        }
                        .opacity(isPickchelinOn ? 1.0 : 0.3)
                    }
                    Button(action: { onMyPickToggle?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(.blackSprout)
                            Text("My Pick")
                                .font(.pretendardCaption2)
                                .foregroundColor(.blackSprout)
                        }
                        .opacity(isMyPickOn ? 1.0 : 0.3)
                    }

                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
}
