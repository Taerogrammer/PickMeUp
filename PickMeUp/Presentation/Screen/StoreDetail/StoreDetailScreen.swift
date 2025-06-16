//
//  StoreDetailScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

struct StoreDetailScreen: View {
    @ObservedObject private var store: StoreDetailStore

    init(store: StoreDetailStore) {
        self.store = store
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if store.state.isLoading {
                VStack {
                    Spacer()
                    ProgressView("가게 정보를 불러오는 중...")
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                .background(Color.gray0)
            } else {
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
                            },
                            store: store
                        )
                        .offset(y: -12)
                    }
                }

                StoreBottomBarView(
                    entity: store.state.storeBottomBarEntity,
                    store: store
                )
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .navigationBarHidden(true)
        .background(Color.gray0)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

//#Preview {
//    StoreDetailScreen(storeID: "asdq", router: AppRouter())
//}
