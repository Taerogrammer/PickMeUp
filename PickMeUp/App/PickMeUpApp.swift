//
//  PickMeUpApp.swift
//  PickMeUp
//
//  Created by 김태형 on 5/10/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct PickMeUpApp: App {
    var body: some Scene {
        WindowGroup {
            LandingView(
                store: Store(
                    initialState: LandingFeature.State(),
                    reducer: { LandingFeature() }
                )
            )
        }
    }
}
