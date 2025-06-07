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
        let state = StoreDetailState(
            storeID: storeID,
            entity: StoreDetailScreenEntity.placeholder(storeID: storeID),
            isLikeLoading: false
        )
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
                VStack(spacing: 0) {
                    StoreImageCarouselView(
                        entity: store.state.storeImageCarouselEntity,
                        onBack: { store.send(.tapBack) },
                        onLike: { store.send(.tapLike) }
                    )

                    StoreDetailMainContentView(
                        summaryEntity: store.state.storeSummaryInfoEntity,
                        detailEntity: store.state.storeDetailInfoEntity,
                        estimatedTimeEntity: store.state.storeEstimatedTimeEntity,
                        categoryTabEntity: store.state.storeMenuCategoryTabEntity,
                        menuListEntity: store.state.storeMenuListEntity,
                        onSelectCategory: { category in
                            store.send(.selectCategory(category))
                        }
                    )
                    .offset(y: -12)
                }
            }

            StoreBottomBarView(entity: store.state.storeBottomBarEntity)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .ignoresSafeArea(.container, edges: .bottom)
        }
        .ignoresSafeArea(.all, edges: .top)
        .navigationBarHidden(true)
        .background(Color.gray0)
        .task {
            store.send(.onAppear)
        }
    }
}

#Preview {
    StoreDetailScreen(storeID: "asdq", router: AppRouter())
}
