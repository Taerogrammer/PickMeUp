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
