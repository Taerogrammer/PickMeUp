//
//  StoreListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListView: View {
    let stores: [StorePresentable]
    let categories: [(image: String, title: String)] = [
        ("coffee", "커피"),
        ("hamburger", "패스트푸드"),
        ("desert", "디저트"),
        ("bread", "베이커리")
    ]

    @State private var selectedCategory: String = "전체"
    @State private var isPickchelinOn: Bool = true
    @State private var isMyPickOn: Bool = false

    var filteredStores: [StorePresentable] {
        var filtered = selectedCategory == "전체"
            ? stores
            : stores.filter { $0.category == selectedCategory }

        if isPickchelinOn {
            filtered = filtered.filter { $0.isPicchelin }
        }
        if isMyPickOn {
            filtered = filtered.filter { $0.isPick }
        }

        return filtered
    }

    var body: some View {
        VStack(spacing: 8) {
            // 카테고리 버튼 스크롤
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryButton(
                        imageName: "more",
                        title: "전체",
                        isSelected: selectedCategory == "전체"
                    ) {
                        selectedCategory = "전체"
                    }

                    ForEach(categories, id: \.title) { category in
                        CategoryButton(
                            imageName: category.image,
                            title: category.title,
                            isSelected: selectedCategory == category.title
                        ) {
                            selectedCategory = category.title
                        }
                    }
                }
                .padding([.top, .leading, .trailing])
                .task {
                    await fetchStores()
                }
            }

            // Section View로 리스트 통합
            ScrollView(showsIndicators: false) {
                StoreSectionView(
                    title: "내가 픽업 가게",
                    stores: filteredStores,
                    showFilter: true,
                    showSortButton: true,
                    onSortTapped: {
                        // 정렬 이벤트 처리
                    },
                    onPickchelinToggle: {
                        isPickchelinOn.toggle()
                    },
                    onMyPickToggle: {
                        isMyPickOn.toggle()
                    },
                    isPickchelinOn: isPickchelinOn,
                    isMyPickOn: isMyPickOn
                )
            }
        }
        .background(Color.gray0)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }

    private func fetchStores() async {
        let query = StoreListRequest(
            category: nil,
            latitude: nil,
            longitude: nil,
            next: nil,
            limit: 5,
            orderBy: .distance
        )
        do {
            let response = try await NetworkManager.shared.fetch(
                StoreRouter.stores(query: query),
                successType: StoreListResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let stores = response.success?.data {
                print("✅ Fetched Stores:", stores.map { $0.name })
            } else if let error = response.failure {
                print("❌ Store fetch 실패: \(error.message)")
            }
        } catch {
            print("❌ Store fetch 예외 발생:", error.localizedDescription)
        }
    }
}



#Preview {
    StoreListView(stores: StoreMockData.samples)
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
