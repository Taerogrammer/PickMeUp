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
        let state = ProfileState(user: MeProfileResponse.mock, profile: MeProfileResponse.mock.toEntity())
        let store = ProfileStore(state: state, router: router)
        return AnyView(ProfileScreen(store: store))
    }

    func makeProfileEditView(user: ProfileEntity) -> AnyView {
        let state = ProfileEditState(profile: user)
        let viewModel = ProfileEditViewModel(initialState: state, router: router)
        return AnyView(ProfileEditView(viewModel: viewModel))
    }
}
