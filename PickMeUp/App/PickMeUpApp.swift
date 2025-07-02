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

    init() {
        setupApplication()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
                .environmentObject(launchState)
        }
    }
    private func setupApplication() {
        NaverMapConfiguration.shared.initialize()
    }
}
