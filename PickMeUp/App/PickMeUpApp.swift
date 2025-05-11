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

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
        }
    }
}
