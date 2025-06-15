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

    init(container: DIContainer) {
        self.container = container
    }

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
                    container.makeTabbarScreen()
                } else {
                    // 로그인 화면은 별도 네비게이션
                    NavigationStack {
                        container.makeLandingView(appLaunchState: launchState)
                    }
                }
            }
        }
    }
}

#Preview {
    let container = DIContainer()
    return AppRootView(container: container)
}
