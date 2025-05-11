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
        LandingView(viewModel: LandingViewModel(router: router))
    }

    func makeRegisterView() -> some View {
        RegisterView()
    }
}
