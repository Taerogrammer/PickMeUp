//
//  ContentView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/10/25.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var launchState: AppLaunchState
    let container: DIContainer

    var body: some View {
        Group {
            if !launchState.didCheckSession {
                ProgressView("세션 확인 중...")
                    .task {
                        let isValid = await AuthService.shared.validateSession()
                        await MainActor.run {
                            launchState.isSessionValid = isValid
                            launchState.didCheckSession = true
                        }
                    }
            } else {
                if launchState.isSessionValid {
                    container.makeTabbarView()
                } else {
                    container.makeLandingView(appLaunchState: launchState)
                }
            }
        }
    }
}

#Preview {
    let container = DIContainer()
    return AppRootView(container: container)
}
