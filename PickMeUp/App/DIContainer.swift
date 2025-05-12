//
//  DIContainer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

final class DIContainer {
    let router = AppRouter()

    func makeLandingView() -> some View {
        LandingView(viewModel: LandingViewModel(router: router), container: self)
    }

    func makeRegisterView() -> some View {
        RegisterView(viewModel: RegisterViewModel(router: router))
    }

    func makeHomeView() -> some View {
        HomeView(viewModel: HomeViewModel(router: router))
    }
}
