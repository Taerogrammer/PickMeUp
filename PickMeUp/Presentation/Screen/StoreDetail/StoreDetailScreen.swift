//
//  StoreDetailScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

struct StoreDetailScreen: View {
    @StateObject private var store: StoreDetailStore

    init(storeID: String, router: AppRouter) {
        let state = StoreDetailState(storeID: storeID)
        _store = StateObject(wrappedValue: StoreDetailStore(
            state: state,
            effect: StoreDetailEffect(),
            reducer: StoreDetailReducer(),
            router: router
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    StoreImageCarouselView(
                        images: store.state.images,
                        onBack: {
                            store.send(.tapBack)
                        },
                        onLike: {
                            store.send(.tapLike)
                        },
                        isLiked: store.state.isLiked
                    )
                    StoreSummaryInfoView(state: store.state)

                    StoreDetailInfoView(
                        address: store.state.address,
                        time: store.state.openHour,
                        parking: store.state.parkingAvailable
                    )

                    StoreEstimatedTimeView(
                        time: store.state.estimatedTime,
                        distance: store.state.distance
                    )

                    StoreNavigationButtonView()

                    StoreMenuCategoryTabView(
                        selected: store.state.selectedCategory,
                        categories: store.state.categories,
                        onSelect: { category in
                            store.send(.selectCategory(category))
                        }
                    )

                    StoreMenuListView(menus: store.state.filteredMenus)
                }
                .padding()
            }

            StoreBottomBarView(
                totalPrice: store.state.totalPrice,
                itemCount: store.state.totalCount
            )
        }
        .navigationBarHidden(true)
        .task {
            store.send(.onAppear)
        }
    }
}



#Preview {
    StoreDetailScreen(storeID: "asdq", router: AppRouter())
}

struct MenuItem: Hashable {
    let name: String
    let description: String
    let image: UIImage
    let isPopular: Bool
    let rank: Int
    let category: String
    let price: Int
    let isSoldOut: Bool
}

struct StoreSummaryInfoView: View {
    let state: StoreDetailState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(state.name)
                    .font(.title2)
                    .bold()
                if state.isPickchelin {
                    Text("픽슐랭")
                        .font(.caption)
                        .padding(4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(6)
                }
                Spacer()
                Image(systemName: "heart")
            }

            HStack(spacing: 8) {
                Label("\(state.likeCount)개", systemImage: "heart.fill")
                    .foregroundColor(.red)
                Label(String(format: "%.1f", state.rating), systemImage: "star.fill")
                    .foregroundColor(.yellow)
            }
            .font(.subheadline)
        }
        .padding(.horizontal)
    }
}

struct StoreDetailInfoView: View {
    let address: String
    let time: String
    let parking: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(address, systemImage: "mappin.and.ellipse")
            Label(time, systemImage: "clock")
            Label(parking, systemImage: "parkingsign.circle")
        }
        .font(.footnote)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct StoreEstimatedTimeView: View {
    let time: String
    let distance: String

    var body: some View {
        HStack {
            Label("예상 소요시간 \(time) (\(distance))", systemImage: "figure.walk")
                .font(.footnote)
                .foregroundColor(.orange)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct StoreNavigationButtonView: View {
    var body: some View {
        Button(action: {
            // TODO: 길찾기 기능 연결
        }) {
            Text("길찾기")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct StoreMenuCategoryTabView: View {
    let selected: String
    let categories: [String]
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        onSelect(category)
                    }) {
                        Text(category)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(category == selected ? Color.orange : Color.gray.opacity(0.2))
                            .foregroundColor(category == selected ? .white : .black)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct StoreMenuListView: View {
    let menus: [MenuItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(menus, id: \.self) { menu in
                StoreMenuItemCardView(menu: menu)
            }
        }
        .padding(.horizontal)
    }
}

struct StoreBottomBarView: View {
    let totalPrice: Int
    let itemCount: Int

    var body: some View {
        HStack {
            Text("\(totalPrice)원")
                .font(.headline)
            Spacer()
            Button(action: {
                // TODO: 결제 기능 연결
            }) {
                HStack {
                    Text("결제하기")
                    if itemCount > 0 {
                        Text("\(itemCount)")
                            .padding(6)
                            .background(Color.white)
                            .clipShape(Circle())
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white.shadow(radius: 4))
    }
}

struct StoreMenuItemCardView: View {
    let menu: MenuItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 메뉴 이미지
            Image(uiImage: menu.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 72)
                .clipped()
                .cornerRadius(8)

            // 메뉴 정보
            VStack(alignment: .leading, spacing: 6) {
                if menu.isPopular {
                    Text("인기 \(menu.rank)위")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .bold()
                }

                Text(menu.name)
                    .font(.headline)

                Text(menu.description)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(menu.price.formatted())원")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }

            Spacer()

            if menu.isSoldOut {
                Text("품절")
                    .font(.caption)
                    .padding(6)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }
}
