//
//  DIContainer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

final class DIContainer: TabProviding, AuthViewProviding, ProfileViewProviding {
    let router = AppRouter()

    // MARK: - TabProviding
    func makeTabbarView() -> AnyView {
        let store = TabbarStore(router: router)
        return AnyView(TabbarView(store: store, container: self))
    }

    // MARK: - AuthViewProviding
    func makeLandingView(appLaunchState: AppLaunchState) -> AnyView {
        let viewModel = LandingViewModel(router: self.router, appLaunchState: appLaunchState)
        return AnyView(LandingView(viewModel: viewModel, container: self))
    }

    func makeRegisterView() -> AnyView {
        let viewModel = RegisterViewModel(router: router)
        return AnyView(RegisterView(viewModel: viewModel))
    }

    // MARK: - ProfileViewProviding
    func makeProfileView() -> AnyView {
        let viewModel = ProfileViewModel(router: router, user: MeProfileResponse.mock)
        return AnyView(ProfileView(viewModel: viewModel))
    }

    func makeProfileEditView(user: ProfileEntity) -> AnyView {
        let state = ProfileEditState(profile: user)
        let viewModel = ProfileEditViewModel(initialState: state, router: router)
        return AnyView(ProfileEditView(viewModel: viewModel))
    }
}
