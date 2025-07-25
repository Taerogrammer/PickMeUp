//
//  ContentView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/10/25.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var launchState: AppLaunchState
    @ObservedObject private var router: AppRouter
    let container: DIContainer

    init(container: DIContainer) {
        self.container = container
        self.router = container.router
    }

    var body: some View {
        NavigationStack(path: $router.currentNavigationPath) {
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
                        TabbarScreen(container: container)
                    } else {
                        container.makeLandingView(appLaunchState: launchState)
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                container.handleNavigation(route: route)
            }
        }
    }
}

#Preview {
    let container = DIContainer()
    return AppRootView(container: container)
}
