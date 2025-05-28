//
//  PickMeUpApp.swift
//  PickMeUp
//
//  Created by 김태형 on 5/10/25.
//

import SwiftUI

@main
struct PickMeUpApp: App {
    let container = DIContainer()
    @State private var isSessionValid = false
    @State private var didCheckSession = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !didCheckSession {
                    ProgressView("세션 확인 중...")
                } else {
                    if isSessionValid {
                        container.makeTabbarView()
                    } else {
                        AppRootView(container: container)
                    }
                }
            }
            .task {
                if !didCheckSession {
                    let isValid = await AuthService.shared.validateSession()
                    isSessionValid = isValid
                    didCheckSession = true
                }
            }
        }
    }
}
