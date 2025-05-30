//
//  DIContainer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

final class DIContainer {
    let router = AppRouter()

    func makeLandingView(appLaunchState: AppLaunchState) -> some View {
        let viewModel = LandingViewModel(router: self.router, appLaunchState: appLaunchState)
        return LandingView(viewModel: viewModel, container: self)
    }

    func makeRegisterView() -> some View {
        RegisterView(viewModel: RegisterViewModel(router: router))
    }

    func makeTabbarView() -> some View {
        let store = TabbarStore(router: router)
        return TabbarView(store: store, container: self)
    }

    // TODO: - 프로토콜
    func makeProfileView() -> some View {
        ProfileView(viewModel: ProfileViewModel(router: router, user: MeProfileResponse.mock))
    }

    func makeProfileEditView(user: ProfileEntity) -> some View {
        let state = ProfileEditState(profile: user)
        let viewModel = ProfileEditViewModel(initialState: state, router: router)
        return ProfileEditView(viewModel: viewModel)
    }
}
