//
//  OrderHistoryStore.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import Foundation

final class OrderHistoryStore: ObservableObject {
    @Published private(set) var state: OrderHistoryState
    private let effect: OrderHistoryEffect
    private let reducer: OrderHistoryReducer

    init(
        state: OrderHistoryState,
        effect: OrderHistoryEffect,
        reducer: OrderHistoryReducer
    ) {
        self.state = state
        self.effect = effect
        self.reducer = reducer
    }

    func send(_ action: OrderHistoryAction.Intent) {
        reducer.reduce(state: &state, action: action)
        effect.handle(action, store: self)
    }

    func send(_ result: OrderHistoryAction.Result) {
        reducer.reduce(state: &state, result: result)
    }
}
