//
//  ProfileStore.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Combine
import Foundation

final class ProfileStore: ObservableObject {
    @Published private(set) var state: ProfileState
    private let reducer: ProfileReducer

    init(state: ProfileState, router: AppRouter) {
        self.state = state
        self.reducer = ProfileReducer(router: router)
    }

    func send(_ intent: ProfileIntent) {
        if case .onAppear = intent {
            ProfileEffect.handleOnAppear(store: self)
        } else {
            reducer.reduce(state: &state, intent: intent)
        }
    }
}
