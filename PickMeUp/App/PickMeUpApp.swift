//
//  PickMeUpApp.swift
//  PickMeUp
//
//  Created by 김태형 on 5/10/25.
//

import SwiftUI

@main
struct PickMeUpApp: App {
    @StateObject private var launchState = AppLaunchState()
    let container = DIContainer()

    var body: some Scene {
        WindowGroup {
            Group {
                if !launchState.didCheckSession {
                    ProgressView("세션 확인 중...")
                } else {
                    if launchState.isSessionValid {
                        container.makeTabbarView()
                    } else {
                        AppRootView(container: container)
                    }
                }
            }
            .environmentObject(launchState)
            .task {
                if !launchState.didCheckSession {
                    let isValid = await AuthService.shared.validateSession()
                    launchState.isSessionValid = isValid
                    launchState.didCheckSession = true
                }
            }
        }
    }
}
