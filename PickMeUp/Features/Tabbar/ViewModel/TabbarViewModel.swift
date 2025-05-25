//
//  TabbarViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import Foundation

final class TabbarViewModel: ObservableObject {
    @Published var state: TabbarState

    private let router: AppRouter

    init(initialState: TabbarState = TabbarState(), router: AppRouter) {
        self.state = initialState
        self.router = router
    }

    func handle(_ intent: TabbarIntent) {
        switch intent {
        case .selectTab(let tab):
            state.selectedTab = tab
        }
    }
}

