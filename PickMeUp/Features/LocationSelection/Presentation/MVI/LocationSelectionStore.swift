//
//  LocationSelectionStore.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import Foundation

final class LocationSelectionStore: ObservableObject {
    @Published private(set) var state: LocationSelectionState
    private let effect: LocationSelectionEffect
    private let reducer: LocationSelectionReducer

    init(state: LocationSelectionState, effect: LocationSelectionEffect, reducer: LocationSelectionReducer) {
        self.state = state
        self.effect = effect
        self.reducer = reducer
    }

    @MainActor
    func send(_ action: LocationSelectionAction.Intent) {
        reducer.reduce(state: &state, action: action)
        effect.handle(action, store: self)
    }

    @MainActor
    func send(_ result: LocationSelectionAction.Result) {
        reducer.reduce(state: &state, result: result)
    }
}
