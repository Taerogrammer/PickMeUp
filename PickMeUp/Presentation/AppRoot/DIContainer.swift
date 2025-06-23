//
//  DIContainer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

final class DIContainer: AuthViewProviding, OrderViewProviding,  ProfileViewProviding, StoreViewProviding, StoreDetailViewProviding {
    let router = AppRouter()

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

    func makeProfileEditScreen(user: ProfileEntity) -> AnyView {
        let state = ProfileEditState(profile: user)
        let effect = ProfileEditEffect()
        let reducer = ProfileEditReducer()
        let store = ProfileEditStore(
            state: state,
            reducer: reducer,
            effect: effect,
            router: self.router
        )
        return AnyView(ProfileEditScreen(store: store))
    }

    // MARK: - StoreViewProviding
    func makeStoreScreen() -> AnyView {
        let state = StoreListState()
        let effect = StoreListEffect()
        let reducer = StoreListReducer()
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
        let effect = StoreDetailEffect()
        let reducer = StoreDetailReducer()
        let store = StoreDetailStore(
            state: state,
            effect: effect,
            reducer: reducer,
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
            makeProfileEditScreen(user: user)
        case .storeDetail(let storeID):
            makeStoreDetailScreen(storeID: storeID)
        case .payment(let paymentInfo):
            makePaymentView(paymentInfo: paymentInfo)
        }
    }
}

