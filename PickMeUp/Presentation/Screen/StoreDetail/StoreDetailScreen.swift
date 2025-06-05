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
        let state = StoreDetailState(storeID: storeID, entity: StoreDetailScreenEntity.placeholder(storeID: storeID))
        _store = StateObject(wrappedValue: StoreDetailStore(
            state: state,
            effect: StoreDetailEffect(),
            reducer: StoreDetailReducer(),
            router: router
        ))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    StoreImageCarouselView(
                        entity: store.state.storeImageCarouselEntity,
                        onBack: { store.send(.tapBack) },
                        onLike: { store.send(.tapLike) }
                    )

                    StoreSummaryInfoView(entity: store.state.storeSummaryInfoEntity)
                    StoreDetailInfoView(entity: store.state.storeDetailInfoEntity)
                    StoreEstimatedTimeView(entity: store.state.storeEstimatedTimeEntity)
                    StoreNavigationButtonView()
                    StoreMenuCategoryTabView(
                        entity: store.state.storeMenuCategoryTabEntity,
                        onSelect: { category in
                            store.send(.selectCategory(category))
                        }
                    )
                    StoreMenuListView(entity: store.state.entity.storeMenuListEntity)
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }

            StoreBottomBarView(entity: store.state.storeBottomBarEntity)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .ignoresSafeArea(.container, edges: .bottom)
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
