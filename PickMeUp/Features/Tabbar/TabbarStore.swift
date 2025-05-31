//
//  TabbarStore.swift
//  PickMeUp
//
//  Created by 김태형 on 5/30/25.
//

import Foundation

final class TabbarStore: ObservableObject {
    @Published private(set) var state: TabbarState
    private let router: AppRouter

    init(state: TabbarState = TabbarState(), router: AppRouter) {
        self.state = state
        self.router = router
    }

    func send(_ intent: TabbarIntent) {
        TabbarReducer.reduce(state: &state, intent: intent)

        Task {
            if let next = await TabbarEffect.handle(intent: intent) {
                send(next)
            }
        }
    }
}
