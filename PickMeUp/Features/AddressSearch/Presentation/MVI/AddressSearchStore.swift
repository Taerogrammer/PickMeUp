//
//  AddressSearchStore.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import Foundation

final class AddressSearchStore: ObservableObject {
    @Published private(set) var state: AddressSearchState
    private let effect: AddressSearchEffect
    private let reducer: AddressSearchReducer

    init(state: AddressSearchState, effect: AddressSearchEffect, reducer: AddressSearchReducer) {
        self.state = state
        self.effect = effect
        self.reducer = reducer
    }

    @MainActor
    func send(_ action: AddressSearchAction.Intent) {
        reducer.reduce(state: &state, intent: action)
        effect.handle(action, store: self)
    }

    @MainActor
    func send(_ result: AddressSearchAction.Result) {
        reducer.reduce(state: &state, result: result)
    }
}
