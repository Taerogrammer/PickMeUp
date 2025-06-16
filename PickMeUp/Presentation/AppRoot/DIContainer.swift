//
//  DIContainer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

final class DIContainer: TabProviding, AuthViewProviding, OrderViewProviding,  ProfileViewProviding, StoreViewProviding, StoreDetailViewProviding {
    let router = AppRouter()

    // MARK: - TabProviding
    func makeTabbarScreen() -> AnyView {
        AnyView(TabbarScreen(container: self))
    }

    // MARK: - AuthViewProviding
    func makeLandingView(appLaunchState: AppLaunchState) -> AnyView {
        let state = LandingState()
        let store = LandingStore(
            initialState: state,
            router: self.router,
            appLaunchState: appLaunchState
        )
        return AnyView(LandingView(store: store))
    }

    func makeRegisterScreen() -> AnyView {
        let store = RegisterStore(router: router)
        return AnyView(RegisterScreen(store: store))
    }

    // MARK: - OrderViewProviding
    func makeOrderScreen() -> AnyView {
        let state = OrderHistoryState()
        let effect = OrderHistoryEffect()
        let reducer = OrderHistoryReducer()

        let store = OrderHistoryStore(
            state: state,
            effect: effect,
            reducer: reducer
        )

        return AnyView(OrderScreen(store: store))
    }

    // MARK: - ProfileViewProviding
    func makeProfileScreen() -> AnyView {
        let state = ProfileState(
            user: MeProfileResponse.empty,
            profile: MeProfileResponse.empty.toEntity()
        )
        let effect = ProfileEffect()
        let reducer = ProfileReducer()

        let store = ProfileStore(
            state: state,
            effect: effect,
            reducer: reducer,
            router: self.router
        )

        return AnyView(ProfileScreen(store: store))
    }

    func makeProfileEditView(user: ProfileEntity) -> AnyView {
        let state = ProfileEditState(profile: user)
        let reducer = ProfileEditReducer()
        let effect = ProfileEditEffect()
        let store = ProfileEditStore(state: state, reducer: reducer, effect: effect, router: router)
        return AnyView(ProfileEditView(store: store))
    }

    // MARK: - StoreViewProviding
    func makeStoreScreen() -> AnyView {
        let state = StoreListState()
        let reducer = StoreListReducer()
        let effect = StoreListEffect()
        let store = StoreListStore(
            state: state,
            effect: effect,
            reducer: reducer,
            router: self.router
        )
        return AnyView(StoreScreen(store: store))
    }

    // MARK: - StoreDetailViewProviding
    func makeStoreDetailScreen(storeID: String) -> AnyView {
        let state = StoreDetailState(
            storeID: storeID,
            entity: StoreDetailScreenEntity.placeholder(storeID: storeID),
            isLikeLoading: false
        )
        let store = StoreDetailStore(
            state: state,
            effect: StoreDetailEffect(),
            reducer: StoreDetailReducer(),
            router: self.router
        )
        return AnyView(StoreDetailScreen(store: store))
    }

    func makePaymentView(paymentInfo: PaymentInfoEntity) -> AnyView {
        return AnyView(PaymentView(
            paymentInfo: paymentInfo,
            router: router
        ))
    }
}

extension DIContainer {
    @ViewBuilder
    func handleNavigation(route: AppRoute) -> some View {
        switch route {
        case .register:
            makeRegisterScreen()
        case .editProfile(let user):
            makeProfileEditView(user: user)
        case .storeDetail(let storeID):
            makeStoreDetailScreen(storeID: storeID)
        case .payment(let paymentInfo):
            makePaymentView(paymentInfo: paymentInfo)
        }
    }
}

