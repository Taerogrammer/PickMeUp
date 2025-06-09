//
//  DIContainer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

final class DIContainer: TabProviding, AuthViewProviding, ProfileViewProviding, StoreViewProviding, StoreDetailViewProviding {
    let router = AppRouter()

    // MARK: - TabProviding
    func makeTabbarScreen() -> AnyView {
        AnyView(TabbarScreen(container: self))
    }

    // MARK: - AuthViewProviding
    func makeLandingView(appLaunchState: AppLaunchState) -> AnyView {
        let viewModel = LandingViewModel(router: self.router, appLaunchState: appLaunchState)
        return AnyView(LandingView(viewModel: viewModel, container: self))
    }

    func makeRegisterScreen() -> AnyView {
        let store = RegisterStore(router: router)
        return AnyView(RegisterScreen(store: store))
    }

    // MARK: - ProfileViewProviding
    func makeProfileScreen() -> AnyView {
        let state = ProfileState(
            user: MeProfileResponse.empty,
            profile: MeProfileResponse.empty.toEntity()
        )
        let reducer = ProfileReducer()
        let effect = ProfileEffect()

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
        return AnyView(StoreDetailScreen(storeID: storeID, router: router))
    }

    func makePaymentView(paymentInfo: PaymentInfo) -> PaymentView {
        return PaymentView(
            paymentInfo: paymentInfo,
            router: router
        )
    }
}
